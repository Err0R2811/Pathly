# Flutter Feature Directive

## Purpose
This directive defines the standard procedure for adding new features to the Pathly Flutter frontend.

## Inputs
- Feature requirements and user stories
- UI/UX mockups or descriptions
- Backend API endpoints to integrate

## Tools/Scripts
- `app/lib/features/` - Feature module directory
- `app/lib/core/services/` - API service layer
- `app/lib/core/router/app_router.dart` - Route definitions

## Outputs
- Complete feature with UI, state management, and API integration
- Proper navigation wiring
- Responsive design for mobile

## Procedure

1. **Create Feature Structure**
   ```
   app/lib/features/feature_name/
   ├── presentation/
   │   └── pages/
   │       └── feature_page.dart
   └── providers/
       └── feature_provider.dart
   ```

2. **Create Service** (if new API integration)
   - Add service file to `app/lib/core/services/`
   - Implement API calls with proper error handling
   - Use Hive for local caching if needed
   - Return typed responses

3. **Create Provider** (if state management needed)
   - Add provider file to feature's providers directory
   - Use Riverpod for state management
   - Define state and notifier classes
   - Handle loading, success, and error states

4. **Build UI**
   - Create page widget in presentation/pages
   - Use existing theme (AppColors, AppTextStyles)
   - Follow design system constants (AppConstants)
   - Implement responsive layout
   - Add loading states and error handling

5. **Add Navigation**
   - Import page in `app/lib/core/router/app_router.dart`
   - Add GoRoute with path and name
   - Pass required parameters
   - Handle navigation from other pages

6. **Update Shell** (if needed)
   - Add navigation item to `app/lib/shared/widgets/app_shell.dart`
   - Update bottom navigation or drawer

## Edge Cases
- Handle network errors gracefully
- Show loading indicators during async operations
- Provide empty states when no data
- Handle authentication failures
- Support dark/light theme

## Notes
- Follow Clean Architecture principles
- Keep UI components reusable
- Use const constructors where possible
- Add comments for complex logic
- Test on both iOS and Android
