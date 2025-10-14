# Indian Cinema DBMS - Backend

## DBMS Course Project

This backend system is designed to manage Indian cinema data, encompassing movies, producers, genres, and box-office performance. It is built to support AI-driven analytics and predictive modeling for revenue forecasting, providing actionable insights for producers, investors, and distributors.

## Features

* Full CRUD operations for Movies, Producers, Genres, and Box Office records
* Advanced search and filtering capabilities
* Analytics endpoints leveraging stored procedures for performance insights
* Complex queries to identify trends and patterns
* Triggers for data validation and audit logging
* RESTful API architecture for seamless integration with frontend or AI modules

## AI & Analytics Focus

* Structured data optimized for machine learning and predictive modeling
* Enables forecasting of movie box-office revenue
* Supports data-driven decision making for the film industry

## Tech Stack

* Python 3.10+
* FastAPI
* MySQL 8.0+
* mysql-connector-python

## Prerequisites

* Python 3.10 or higher
* MySQL 8.0 or higher
* pip (Python package manager)

## Installation

1. Clone the repository:

```bash
git clone https://github.com/aaronmat1905/IndianMovieAnalytics
cd indian-cinema-dbms-backend
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Configure your MySQL connection in `config.py`.
4. Start the FastAPI server:

```bash
uvicorn main:app --reload
```

---

## Team

1. [**Aaron Thomas Mathew**](https://github.com/aaronmat1905)
2. [**Aashlesh Lokesh**](https://github.com/aashlesh-lokesh)
