from flask import Flask, request, jsonify
from flask_cors import CORS
from database_wrapper import DatabaseWrapper

app = Flask(__name__)
CORS(app)

db = DatabaseWrapper()

@app.route('/products', methods=['GET'])
def get_products():
    return jsonify(db.get_products())

@app.route('/products', methods=['POST'])
def add_product():
    data = request.json

    db.add_product(
        data['name'],
        data['price'],
        data['image'],
        data['category']
    )

    return jsonify({'message': 'ok'})

@app.route('/products/<int:id>', methods=['PUT'])
def update_product(id):
    data = request.json

    db.update_product(
        id,
        data['name'],
        data['price'],
        data['image'],
        data['category']
    )

    return jsonify({'message': 'updated'})

@app.route('/products/<int:id>', methods=['DELETE'])
def delete_product(id):
    db.delete_product(id)
    return jsonify({'message': 'deleted'})

@app.route('/orders', methods=['GET'])
def get_orders():
    return jsonify(db.get_orders())

@app.route('/orders', methods=['POST'])
def create_order():
    data = request.json

    order_id = db.create_order(
        data['total'],
        'IN ATTESA'
    )

    for item in data['items']:
        db.add_order_item(
            order_id,
            item['name'],
            item['quantity'],
            item['price']
        )

    return jsonify({'message': 'order created'})

@app.route('/orders/<int:id>', methods=['PUT'])
def update_order(id):
    data = request.json

    db.update_order_status(id, data['status'])

    return jsonify({'message': 'status updated'})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)