const express = require('express');
const mysql = require('mysql2/promise');   // <-- NEW: MySQL library
const app = express();
app.use(express.json());

// NEW: Create MySQL connection pool
const pool = mysql.createPool({
  host: 'mysql-service',                   // <-- NEW: K8s MySQL service name
  user: 'lugxuser',                        // <-- NEW: user from mysql.yaml
  password: 'lugxpass',                    // <-- NEW: password from mysql.yaml
  database: 'lugx'                         // <-- NEW: DB name
});

// Create a new order
app.post('/', async (req, res) => {
  const { user_id, items, total_price } = req.body;
  try {
    const [result] = await pool.execute(
      'INSERT INTO orders (user_id, items, total_price) VALUES (?, ?, ?)',
      [user_id, JSON.stringify(items), total_price]
    );
    res.status(201).json({ id: result.insertId, user_id, items, total_price });
  } catch (err) {
    console.error(err);
    res.status(500).send("Error inserting order");
  }
});

// Get all orders
app.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM orders');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error retrieving orders");
  }
});

app.listen(3001, () => console.log("Order Service connected to MySQL on port 3001"));
