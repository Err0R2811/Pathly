"""YouTube video search service for curriculum resources."""

from __future__ import annotations

import json
import os

import httpx

YOUTUBE_API_KEY = os.getenv("YOUTUBE_API_KEY", "")

# Simple in-memory cache for YouTube search results
_youtube_cache: dict[str, list[dict[str, str]]] = {}


async def search_youtube_videos(
    query: str,
    max_results: int = 5,
    min_duration: int = 300,  # 5 minutes minimum
) -> list[dict[str, str]]:
    """Search YouTube for educational videos related to a topic.

    Args:
        query: Search query for videos
        max_results: Maximum number of results to return
        min_duration: Minimum video duration in seconds

    Returns:
        List of video dictionaries with title, url, duration, channel
    """
    # Create cache key from query and max_results
    cache_key = f"{query}:{max_results}:{min_duration}"

    # Check cache first
    if cache_key in _youtube_cache:
        print(f"[youtube] Cache hit for query: {query}")
        return _youtube_cache[cache_key]

    if not YOUTUBE_API_KEY:
        # No API key: try to scrape real YouTube search results before giving up
        try:
            scraped = await _scrape_youtube_search(query, max_results)
            _youtube_cache[cache_key] = scraped
            return scraped
        except Exception as exc:
            print(f"[youtube] Scrape failed: {exc}, using search link fallback")
        fallback = _get_search_link_videos(query, max_results)
        _youtube_cache[cache_key] = fallback
        return fallback

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            # Search for videos
            search_url = "https://www.googleapis.com/youtube/v3/search"
            search_params = {
                "part": "snippet",
                "q": query,
                "type": "video",
                "maxResults": max_results * 2,  # Get more to filter by duration
                "key": YOUTUBE_API_KEY,
                "order": "relevance",
                "videoDuration": "long",  # Prefer longer videos
            }

            response = await client.get(search_url, params=search_params)
            response.raise_for_status()
            search_data = response.json()

            video_ids = [item["id"]["videoId"] for item in search_data.get("items", [])]

            if not video_ids:
                return _get_search_link_videos(query, max_results)

            # Get video details including duration
            details_url = "https://www.googleapis.com/youtube/v3/videos"
            details_params = {"part": "contentDetails,snippet", "id": ",".join(video_ids), "key": YOUTUBE_API_KEY}

            response = await client.get(details_url, params=details_params)
            response.raise_for_status()
            details_data = response.json()

            # Parse duration and filter
            videos = []
            for item in details_data.get("items", []):
                duration_str = item["contentDetails"]["duration"]
                duration_seconds = _parse_duration(duration_str)

                if duration_seconds >= min_duration:
                    video_id = item["id"]
                    videos.append(
                        {
                            "title": item["snippet"]["title"],
                            "url": f"https://www.youtube.com/watch?v={video_id}",
                            "duration": duration_seconds,
                            "duration_formatted": _format_duration(duration_seconds),
                            "channel": item["snippet"]["channelTitle"],
                            "thumbnail": item["snippet"]["thumbnails"]["default"]["url"],
                        }
                    )

                if len(videos) >= max_results:
                    break

            # Cache the results
            _youtube_cache[cache_key] = videos
            return videos if videos else _get_search_link_videos(query, max_results)

    except Exception as exc:
        print(f"[youtube] Search failed: {exc}, using fallback")
        fallback = _get_search_link_videos(query, max_results)
        _youtube_cache[cache_key] = fallback
        return fallback


async def _scrape_youtube_search(query: str, max_results: int) -> list[dict[str, str]]:
    """Scrape real video IDs from YouTube search results page."""
    import re
    import urllib.parse

    encoded_query = urllib.parse.quote_plus(query)
    search_url = f"https://www.youtube.com/results?search_query={encoded_query}"

    async with httpx.AsyncClient(timeout=15.0, follow_redirects=True) as client:
        headers = {
            "User-Agent": (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/120.0.0.0 Safari/537.36"
            ),
            "Accept-Language": "en-US,en;q=0.9",
        }
        response = await client.get(search_url, headers=headers)
        response.raise_for_status()
        html = response.text

    # Extract ytInitialData JSON
    match = re.search(r"var ytInitialData = ({.*?});</script>", html, re.DOTALL)
    if not match:
        raise Exception("Could not find YouTube initial data")

    data = json.loads(match.group(1))

    # Try to locate video renderers in the nested response
    videos = []
    seen = set()
    contents = (
        data.get("contents", {})
        .get("twoColumnSearchResultsRenderer", {})
        .get("primaryContents", {})
        .get("sectionListRenderer", {})
        .get("contents", [])
    )

    for section in contents:
        item_section = section.get("itemSectionRenderer", {})
        for item in item_section.get("contents", []):
            video = item.get("videoRenderer") or item.get("compactVideoRenderer")
            if not video:
                continue
            video_id = video.get("videoId")
            if not video_id or video_id in seen:
                continue

            title_runs = video.get("title", {}).get("runs", [])
            title = " ".join(run.get("text", "") for run in title_runs).strip() or f"{query} tutorial"

            videos.append(
                {
                    "title": title,
                    "url": f"https://www.youtube.com/watch?v={video_id}",
                    "duration": 0,
                    "duration_formatted": "",
                    "channel": "YouTube",
                    "thumbnail": f"https://i.ytimg.com/vi/{video_id}/mqdefault.jpg",
                }
            )
            seen.add(video_id)

            if len(videos) >= max_results:
                break
        if len(videos) >= max_results:
            break

    if not videos:
        raise Exception("No videos found in search results")

    return videos


def _get_search_link_videos(query: str, max_results: int) -> list[dict[str, str]]:
    """Last-resort fallback: return a topic-specific YouTube search results link."""
    encoded_query = "+".join(query.split())
    return [
        {
            "title": f"Search YouTube for {query} tutorials",
            "url": f"https://www.youtube.com/results?search_query={encoded_query}",
            "duration": 0,
            "duration_formatted": "Search",
            "channel": "YouTube",
            "thumbnail": "https://via.placeholder.com/320x180",
        },
    ]


def _parse_duration(duration_str: str) -> int:
    """Parse YouTube duration format (PT1H2M3S) to seconds."""
    import re

    pattern = r"PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?"
    match = re.match(pattern, duration_str)

    if not match:
        return 0

    hours = int(match.group(1) or 0)
    minutes = int(match.group(2) or 0)
    seconds = int(match.group(3) or 0)

    return hours * 3600 + minutes * 60 + seconds


def _format_duration(seconds: int) -> str:
    """Format seconds to human-readable duration."""
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    secs = seconds % 60

    if hours > 0:
        return f"{hours}h {minutes}m"
    elif minutes > 0:
        return f"{minutes}m {secs}s"
    else:
        return f"{secs}s"
