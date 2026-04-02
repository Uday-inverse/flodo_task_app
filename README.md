# Flodo Task Management App

A Flutter-based Task Management application built for the Flodo AI take-home assignment.

## Chosen Track
**Track B: Mobile Specialist**

## Stretch Goal
No optional stretch goal was implemented.  
I prioritized completing all required core features with a polished and stable user experience.

## Features Implemented

- Create, read, update, and delete tasks
- Each task includes:
  - Title
  - Description
  - Due Date
  - Status (`To-Do`, `In Progress`, `Done`)
  - Optional `Blocked By` dependency
- Main list view for all tasks
- Blocked task UI:
  - If a task is blocked by another unfinished task, it appears visually distinct
- Search tasks by title
- Filter tasks by status
- Draft persistence:
  - If the user leaves the task creation screen before saving, typed input is restored
- Simulated 2-second delay on task creation and update
- Loading state during save/update
- Save button disabled while loading
- Local persistence across app restarts

## Tech Stack
- Flutter
- Dart
- Provider
- Hive
- SharedPreferences
- Intl
- UUID

## Project Structure
text
lib/
  models/
  providers/
  screens/
  services/
  widgets/
  main.dart
