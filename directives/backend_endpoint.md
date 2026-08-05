# Backend Endpoint Directive

## Purpose
This directive defines the standard procedure for adding new API endpoints to the Pathly backend.

## Inputs
- Endpoint purpose and requirements
- Request/response schema definitions
- Authentication requirements (public, authenticated, admin-only)

## Tools/Scripts
- `backend/app/routers/` - Router files for endpoint definitions
- `backend/app/schemas.py` - Pydantic schemas for request/response validation
- `backend/app/models.py` - SQLAlchemy ORM models (if new entities needed)

## Outputs
- Working API endpoint with proper error handling
- Updated OpenAPI documentation
- Test coverage for the endpoint

## Procedure

1. **Define Schemas** (if new)
   - Add request schema to `backend/app/schemas.py`
   - Add response schema to `backend/app/schemas.py`
   - Include validation rules and field descriptions

2. **Create Router** (if new)
   - Create new file in `backend/app/routers/`
   - Import dependencies: FastAPI, Session, models, schemas
   - Define router with prefix and tags
   - Add authentication dependency if needed

3. **Implement Endpoint**
   - Define route with appropriate HTTP method
   - Add path parameters and query parameters
   - Implement business logic
   - Add error handling (404, 401, 400, 500)
   - Return validated response

4. **Register Router**
   - Import router in `backend/app/main.py`
   - Include router with `app.include_router()`

5. **Write Tests**
   - Create test file in `backend/tests/`
   - Test success cases
   - Test error cases
   - Test authentication if applicable

## Edge Cases
- Handle database connection errors gracefully
- Validate all inputs before processing
- Return appropriate HTTP status codes
- Log errors for debugging

## Notes
- Use async/await for I/O operations
- Follow existing code style and patterns
- Add docstrings to all functions
- Keep endpoints focused and single-purpose
