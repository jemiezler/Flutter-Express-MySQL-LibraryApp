# Flutter Express Project

A full-stack application combining a Flutter frontend with an Express.js backend. This project is organized into two separate folders:

- **`Frontend/`**: The Flutter application.
- **`Backend/`**: The Express.js backend API.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Folder Structure](#folder-structure)
- [Setup](#setup)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [Running the Project](#running-the-project)
- [API Documentation](#api-documentation)
- [License](#license)

## Features

- Flutter-powered cross-platform user interface.
- Express.js backend for handling API requests.
- Realtime functionality using Socket.IO (optional).
- Authentication mechanisms.

## Requirements

Ensure you have the following installed:

- **Node.js** (for the backend): [Download Node.js](https://nodejs.org/)
- **Flutter** (for the frontend): [Install Flutter](https://flutter.dev/docs/get-started/install)
- **SQL Database** (as per backend requirements)
- **Git** (to clone the repository)

## Folder Structure


## Setup

### Backend Setup

1. Navigate to the `backend/` folder:
   ```bash
   cd backend
   ```
2. install dependency to `backend/`:
   ```bash
   npm i
   ```
### Frontend Setup
1. Navigate to the `backend/` folder:
   ```bash
   cd frontend
   ```
2. install dependency to `frontend/`:
   ```bash
   flutter pub get
   ```

## Running the Project
1. run the `backend/` project using:
   ```bash
   npx nodemon server.js
   ```
2. run the `frontend/` project using:
   ```bash
   flutter run
   ```

