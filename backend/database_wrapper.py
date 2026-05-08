import pymysql
from config import DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME

class DatabaseWrapper:
    def connect(self):
        return pymysql.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )

    def get_products(self):
        conn = self.connect()
        cur = conn.cursor()
        cur.execute("SELECT * FROM products")
        data = cur.fetchall()
        conn.close()
        return data

    def add_product(self, name, price, image, category):
        conn = self.connect()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO products(name, price, image, category) VALUES(%s, %s, %s, %s)",
            (name, price, image, category)
        )
        conn.commit()
        conn.close()

    def update_product(self, id, name, price, image, category):
        conn = self.connect()
        cur = conn.cursor()
        cur.execute(
            "UPDATE products SET name=%s, price=%s, image=%s, category=%s WHERE id=%s",
            (name, price, image, category, id)
        )
        conn.commit()
        conn.close()

    def delete_product(self, id):
        conn = self.connect()
        cur = conn.cursor()
        cur.execute("DELETE FROM products WHERE id=%s", (id,))
        conn.commit()
        conn.close()

    def create_order(self, total, status):
        conn = self.connect()
        cur = conn.cursor()
        cur.execute("INSERT INTO orders(total, status) VALUES(%s,%s)", (total, status))
        conn.commit()
        order_id = cur.lastrowid
        conn.close()
        return order_id

    def add_order_item(self, order_id, product_name, quantity, price):
        conn = self.connect()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO order_items(order_id, product_name, quantity, price) VALUES(%s,%s,%s,%s)",
            (order_id, product_name, quantity, price)
        )
        conn.commit()
        conn.close()

    def get_orders(self):
        conn = self.connect()
        cur = conn.cursor()
        cur.execute("SELECT * FROM orders ORDER BY id DESC")
        data = cur.fetchall()
        conn.close()
        return data

    def update_order_status(self, id, status):
        conn = self.connect()
        cur = conn.cursor()
        cur.execute("UPDATE orders SET status=%s WHERE id=%s", (status, id))
        conn.commit()
        conn.close()