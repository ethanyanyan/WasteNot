# Git Workflow and Branching Guidelines

This document outlines the Git workflow, commit practices, branching strategy, and pull request (PR) guidelines for the WasteNot project.

## 1. Branching Strategy

- **Main Branch (`main`):**

  - The `main` branch always contains production-ready, stable code.
  - All features and fixes must be merged into `main` only after code reviews and testing.

- **Feature Branches:**

  - Create a new branch for every new feature, improvement, or bug fix.
  - Branch naming convention: `feature/<short-description>`, `bugfix/<short-description>`, or `hotfix/<short-description>`.
  - Example: `feature/aws-auth` or `bugfix/fix-login-error`.

- **Release Branches (if needed):**

  - For major releases, you can create a release branch (e.g., `release/v1.0`).
  - Once final testing is complete, merge the release branch into `main` and tag the release.

- **Branch Creation Example:**
  ```bash
  git checkout -b feature/your-feature-name
  ```

## 2. Commit Practices

- **Commit Messages:**

  - Write clear, concise commit messages that explain the "what" and "why" of the changes.
  - Use the following format:

    ```
    <type>(<scope>): <subject>

    <body>

    <footer>
    ```

  - **Type examples:** `feat` (new feature), `fix` (bug fix), `docs` (documentation), `style` (formatting), `refactor` (code restructuring), `test` (adding tests), `chore` (maintenance tasks).
  - **Example:**

    ```
    feat(auth): add AWS Cognito user sign-up

    Implemented sign-up flow using AWS Cognito for user authentication.
    ```

- **Commit Often:**
  - Make small, atomic commits to simplify reviews and troubleshooting.
  - Ensure that each commit represents a logical piece of work.

## 3. Pull Request (PR) Guidelines

- **Creating a PR:**

  - When a feature branch is complete, push your branch to the remote repository:
    ```bash
    git push -u origin feature/your-feature-name
    ```
  - Open a PR from your feature branch into `main` on GitHub.
  - Include a descriptive title and summary in the PR that explains:
    - What was implemented or fixed.
    - How to test the changes.
    - Any known issues or areas needing further review.

- **Review Process:**
  - All PRs must be reviewed by at least one other team member before merging.
  - Address any feedback or requested changes.
  - Once approved, merge the PR using a **merge commit** or **squash merging** as agreed upon by the team.
  - Delete the feature branch after the PR is merged to keep the repository clean.

## 4. Additional Guidelines

- **Rebasing:**
  - When working on long-running branches, regularly rebase your branch on `main` to minimize merge conflicts.
  ```bash
  git fetch origin
  git rebase origin/main
  ```
- **Conflict Resolution:**
  - If conflicts occur, resolve them locally, commit the changes, and push the updated branch.
- **Issue References:**
  - Include references to relevant GitHub issues in your commit messages or PR descriptions (e.g., `Fixes #12`).

By following these guidelines, we can ensure a consistent and efficient workflow that supports collaborative development and maintains the integrity of our codebase.
