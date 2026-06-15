from flask import Flask, render_template
import mysql.connector
import boto3
import os
from datetime import datetime

app = Flask(__name__)

DB_HOST = os.environ.get('DB_HOST', 'rds-mysql')
DB_PORT = os.environ.get('DB_PORT', '3306')
DB_NAME = os.environ.get('DB_NAME', 'urlshortener')
DB_USER = os.environ.get('DB_USERNAME', 'root')
DB_PASS = os.environ.get('DB_PASSWORD', '')
DB_IDENTIFIER = os.environ.get('DB_IDENTIFIER', 'dev-mysql-db')
AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')

def get_db_connection():
    return mysql.connector.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )

def get_rds_info():
    """Discover RDS endpoint using AWS API via Pod Identity credentials"""
    try:
        rds_client = boto3.client('rds', region_name=AWS_REGION)
        response = rds_client.describe_db_instances(DBInstanceIdentifier=DB_IDENTIFIER)
        
        if response['DBInstances']:
            db_instance = response['DBInstances'][0]
            return {
                'endpoint': db_instance.get('Endpoint', {}).get('Address', 'N/A'),
                'port': db_instance.get('Endpoint', {}).get('Port', 'N/A'),
                'region': AWS_REGION,
                'arn': db_instance.get('DBInstanceArn', 'N/A'),
                'status': db_instance.get('DBInstanceStatus', 'N/A')
            }
    except Exception as e:
        print(f"RDS discovery error: {e}")
    
    return {
        'endpoint': 'N/A',
        'port': 'N/A',
        'region': AWS_REGION,
        'arn': 'N/A',
        'status': 'N/A'
    }

def init_db():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Create employees table
        cur.execute("""
            CREATE TABLE IF NOT EXISTS employees (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                email VARCHAR(255) UNIQUE NOT NULL,
                department VARCHAR(100) NOT NULL,
                salary DECIMAL(10, 2) NOT NULL,
                joined_date DATE NOT NULL
            )
        """)
        
        # Check if table already has data
        cur.execute("SELECT COUNT(*) FROM employees")
        count = cur.fetchone()[0]
        
        if count == 0:
            # Insert dummy employee data
            employees = [
                ('Alice Johnson', 'alice.johnson@dev.com', 'Engineering', 95000.00, '2022-03-15'),
                ('Bob Smith', 'bob.smith@dev.com', 'Marketing', 72000.00, '2021-07-22'),
                ('Carol Davis', 'carol.davis@dev.com', 'Engineering', 105000.00, '2020-11-08'),
                ('David Wilson', 'david.wilson@dev.com', 'Sales', 68000.00, '2023-01-10'),
                ('Eva Brown', 'eva.brown@dev.com', 'HR', 65000.00, '2022-09-01'),
                ('Frank Miller', 'frank.miller@dev.com', 'Engineering', 88000.00, '2021-05-18'),
                ('Grace Lee', 'grace.lee@dev.com', 'Product', 92000.00, '2023-03-20'),
                ('Henry Taylor', 'henry.taylor@dev.com', 'Finance', 78000.00, '2022-12-05')
            ]
            
            cur.executemany("""
                INSERT INTO employees (name, email, department, salary, joined_date)
                VALUES (%s, %s, %s, %s, %s)
            """, employees)
        
        conn.commit()
        cur.close()
        conn.close()
        return True
    except Exception as e:
        print(f"Database init error: {e}")
        return False

def get_status_data():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("SELECT * FROM employees ORDER BY joined_date DESC")
        rows = cur.fetchall()
        
        # Get RDS version
        cur.execute("SELECT VERSION()")
        version = cur.fetchone()[0]
        
        cur.close()
        conn.close()
        
        # Discover RDS info via AWS API
        rds_info = get_rds_info()
        
        return {
            'connected': True,
            'rows': rows,
            'version': version,
            'host': DB_HOST,
            'database': DB_NAME,
            'user': DB_USER,
            'rds_endpoint': rds_info['endpoint'],
            'rds_port': rds_info['port'],
            'rds_region': rds_info['region'],
            'rds_status': rds_info['status'],
            'rds_arn': rds_info['arn'],
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        }
    except Exception as e:
        return {
            'connected': False,
            'error': str(e),
            'host': DB_HOST,
            'database': DB_NAME,
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        }

# Initialize DB on startup
@app.before_request
def before_request():
    if not getattr(app, '_db_initialized', False):
        app._db_initialized = init_db()

@app.route('/')
def index():
    status = get_status_data()
    return render_template('index.html', status=status)

@app.route('/health')
def health():
    return {'status': 'healthy'}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
