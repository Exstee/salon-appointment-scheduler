# Salon Appointment Scheduler

This project is part of the [freeCodeCamp Relational Database Certification](https://www.freecodecamp.org/learn/relational-database/). It implements a salon appointment scheduling system using PostgreSQL and a Bash script to manage customer appointments for various salon services.

## Project Overview

The Salon Appointment Scheduler allows users to:
- View a list of available salon services.
- Select a service and provide their phone number and name.
- Schedule an appointment at a specified time.
- Store customer and appointment data in a PostgreSQL database.

The system ensures data integrity with foreign key constraints and validates user input to prevent errors.

## Files

- **`salon.sql`**: Defines the PostgreSQL database schema and initial data.
- **`salon.sh`**: A Bash script that interacts with the database, providing a command-line interface for scheduling appointments.

## Database Schema

The database (`salon`) consists of three tables:

### `customers`
| Column       | Type                | Constraints                     | Description                          |
|--------------|---------------------|----------------------------------|--------------------------------------|
| `customer_id`| `INTEGER`           | `PRIMARY KEY`, Auto-increment    | Unique identifier for a customer.    |
| `phone`      | `VARCHAR(15)`       | `NOT NULL`, `UNIQUE`            | Customer's phone number.            |
| `name`       | `VARCHAR(40)`       | `NOT NULL`                      | Customer's name.                    |

### `services`
| Column       | Type                | Constraints                     | Description                          |
|--------------|---------------------|----------------------------------|--------------------------------------|
| `service_id` | `INTEGER`           | `PRIMARY KEY`, Auto-increment    | Unique identifier for a service.     |
| `name`       | `VARCHAR(40)`       | `NOT NULL`                      | Name of the salon service.          |

### `appointments`
| Column         | Type                | Constraints                     | Description                          |
|----------------|---------------------|----------------------------------|--------------------------------------|
| `appointment_id`| `INTEGER`          | `PRIMARY KEY`, Auto-increment    | Unique identifier for an appointment.|
| `customer_id`  | `INTEGER`           | `NOT NULL`, `FOREIGN KEY`        | References `customers(customer_id)`. |
| `service_id`   | `INTEGER`           | `NOT NULL`, `FOREIGN KEY`        | References `services(service_id)`.   |
| `time`         | `VARCHAR(8)`        | `NOT NULL`                      | Appointment time (e.g., '7:00 PM'). |

### Sample Data
- **Services**: Includes 10 services like Haircut, Hair Color, Highlights, Balayage, Perm, Blowout, Keratin Treatment, Deep Conditioning, Beard Trim, and Neck Trim.
- **Customers**: Example entry with `customer_id=1`, `phone='123-456-7890'`, `name='Your Name Here'`.
- **Appointments**: Example entry linking a customer to a Haircut at '7:00 PM'.

## Setup Instructions

1. **Install PostgreSQL**:
   - Ensure PostgreSQL is installed (version 12 or compatible). On Ubuntu, run:
     ```bash
     sudo apt-get install postgresql
     ```
   - Verify installation: `psql --version`.

2. **Create the Database**:
   - Log in to PostgreSQL as a superuser (e.g., `postgres`):
     ```bash
     psql -U postgres
     ```
   - Create the database user and database:
     ```sql
     CREATE USER freecodecamp WITH PASSWORD 'your_password';
     CREATE DATABASE salon;
     GRANT ALL PRIVILEGES ON DATABASE salon TO freecodecamp;
     ```
   - Exit: `\q`.

3. **Load the Database Schema**:
   - Run the `salon.sql` script to create tables and insert initial data:
     ```bash
     psql -U freecodecamp -d salon -f salon.sql
     ```

4. **Run the Scheduler**:
   - Make the Bash script executable:
     ```bash
     chmod +x salon.sh
     ```
   - Execute the script:
     ```bash
     ./salon.sh
     ```

## Usage

1. Run `./salon.sh` in your terminal.
2. The script displays a list of services (e.g., `1) Haircut`, `2) Hair Color`).
3. Enter the service number, your phone number, name (if new), and desired appointment time.
4. The script validates input and stores the appointment in the database, displaying a confirmation (e.g., "I have put you down for a Haircut at 7:00 PM, Carl.").

## Notes
- The script includes basic input validation (e.g., numeric service IDs, phone number format) and error handling for database connectivity.
- To check data, use SQL queries like:
  ```sql
  SELECT * FROM appointments;
  SELECT c.name, s.name AS service, a.time 
  FROM appointments a
  JOIN customers c ON a.customer_id = c.customer_id
  JOIN services s ON a.service_id = s.service_id;
  ```
