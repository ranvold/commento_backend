# Commento API

Backend for the test task "Build app for comments and notifications".

This repository contains the Rails API only. The React frontend lives in a separate repository and is deployed to Vercel.

## Live Demo

- Frontend: https://commento-frontend.vercel.app
- Backend: deployed to Render

The production API is configured to accept requests from the Vercel frontend and to use Meilisearch in production.

## Task Coverage

The implementation covers the requested scope:

- Rails 8.1 API-only application
- Simple token-based authentication
- Comment model with CRUD endpoints
- Meilisearch integration for comment search in production
- Notification model
- Mention notifications when a user is referenced as `@username` in a comment
- Mark one notification or all notifications as read
- Clean separation between controllers, operations, queries, jobs, and models

## How It Works

### Authentication

- Authentication is implemented with `has_secure_password` on `User`
- Sessions return a bearer token stored in the `api_tokens` table
- Tokens expire after 24 hours
- Every protected endpoint expects `Authorization: Bearer <token>`

### Comments

- Authenticated users can create, list, update, and delete their own comments
- `GET /api/v1/comments` returns paginated comments ordered by newest first
- `PATCH /api/v1/comments/:id` is owner-only
- `DELETE /api/v1/comments/:id` is owner-only

### Search

- Searching is done through the `query` param on `GET /api/v1/comments`
- In production, search uses Meilisearch with sorting by `created_at desc`
- In development and test, the app falls back to PostgreSQL `ILIKE` search when Meilisearch is inactive

### Notifications

- Mention notifications are stored in the `notifications` table with `kind: mention`
- When a comment is created with mentions, a background job resolves mentioned usernames and creates notifications
- When a comment is edited, mention changes are reconciled: new mentions are added and removed mentions are deleted
- Notifications can be listed, counted, marked individually as read, or marked all at once as read
- The API also broadcasts notification changes through Action Cable / Solid Cable

## Reviewer Flow

Fastest way to review the task from the UI:

1. Open the frontend at https://commento-frontend.vercel.app
2. Sign up two different users
3. Create a comment as one user mentioning the other, for example `Hello @alice`
4. Sign in as the mentioned user and open notifications
5. Mark a notification as read
6. Search comments by body text
7. Edit the original comment and change the mentioned usernames to verify notification reconciliation

## API Surface

Base path: `/api/v1`

### Auth and user endpoints

- `POST /signup` - create user and immediately issue a token
- `POST /session` - log in and issue a token
- `DELETE /session` - log out by deleting the current token
- `GET /me` - return the currently authenticated user
- `GET /users?query=ali` - search users by username for mention suggestions

### Comment endpoints

- `GET /comments?page=1&query=hello` - list comments, optionally filtered by body
- `POST /comments` - create comment
- `PATCH /comments/:id` - update owned comment
- `DELETE /comments/:id` - delete owned comment

### Notification endpoints

- `GET /notifications?page=1` - list current user's notifications
- `GET /notifications/unread_count` - unread notification counter
- `PATCH /notifications/:id/mark_as_read` - mark one notification as read
- `PATCH /notifications/mark_all_as_read` - mark all current user's unread notifications as read

## Example Requests

```bash
BASE_URL=http://localhost:3000/api/v1
```

Sign up:

```bash
curl -X POST "$BASE_URL/signup" \
	-H "Content-Type: application/json" \
	-d '{"signup":{"username":"alice","password":"s3cr3t!"}}'
```

Log in:

```bash
curl -X POST "$BASE_URL/session" \
	-H "Content-Type: application/json" \
	-d '{"session":{"username":"alice","password":"s3cr3t!"}}'
```

Create a comment:

```bash
curl -X POST "$BASE_URL/comments" \
	-H "Authorization: Bearer <token>" \
	-H "Content-Type: application/json" \
	-d '{"comment":{"body":"Hello @bob"}}'
```

Search comments:

```bash
curl "$BASE_URL/comments?query=hello" \
	-H "Authorization: Bearer <token>"
```

List notifications:

```bash
curl "$BASE_URL/notifications" \
	-H "Authorization: Bearer <token>"
```

Mark one notification as read:

```bash
curl -X PATCH "$BASE_URL/notifications/1/mark_as_read" \
	-H "Authorization: Bearer <token>"
```

## Local Setup

### Requirements

- Ruby 4.0.4
- PostgreSQL
- Bundler

Optional for production-like local testing:

- Meilisearch

### Boot the app

Install dependencies and prepare the database:

```bash
bin/setup --skip-server
```

Start the Rails API:

```bash
bin/dev
```

The API will be available at `http://localhost:3000`.

### Notes about search locally

Meilisearch is enabled only in production configuration. In development and test, search still works through the Active Record fallback, so a reviewer can verify the search feature locally without running Meilisearch.

To exercise the Meilisearch-backed path in production-style environments, configure:

- `MEILISEARCH_HOST`
- `MEILISEARCH_API_KEY`
- `DATABASE_URL` in production deployments

Optional production Action Cable origin overrides:

- `ACTION_CABLE_ALLOWED_ORIGINS`

## Testing and API Docs

Run the test suite:

```bash
bundle exec rspec
```

Run the project CI command:

```bash
bin/ci
```

Swagger/OpenAPI docs are generated from request specs and are available locally at:

- `http://localhost:3000/api-docs`

Generated OpenAPI file:

- `swagger/v1/swagger.yaml`

## Project Structure

```text
app/
	controllers/   HTTP layer and authentication
	models/        persistence and simple domain behavior
	operations/    business actions such as login, signup, comment, and notification flows
	queries/       reusable search/query objects
	jobs/          background processing for mention handling
	broadcasts/    Action Cable notification broadcasts
```

Important implementation details:

- mention extraction lives on `Comment#mentioned_usernames`
- comment creation queues mention processing
- comment updates reconcile added and removed mentions
- notification lists are paginated with Pagy
- real-time notification updates are published on `users:<id>:notifications`

## Notes for Reviewer

- This repository is the backend part of the assignment
- The frontend was intentionally split into a separate React repository and deployed independently to Vercel
- No seed demo accounts are included, so the expected review path is to create users through `POST /api/v1/signup` or through the deployed frontend
