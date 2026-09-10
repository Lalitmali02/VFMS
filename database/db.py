import mysql.connector


def get_connection():
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password="Lalit@2006",
        database="vfms_db"
    )

    return connection


# Test database connection
if __name__ == "__main__":
    try:
        connection = get_connection()

        if connection.is_connected():
            print("MySQL database connected successfully!")

        connection.close()

    except mysql.connector.Error as error:
        print("Database connection failed!")
        print(error)