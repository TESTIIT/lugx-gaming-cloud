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

// Add a new game
app.post('/', async (req, res) => {
  const { name, category, release_date, price } = req.body;
  try {
    const [result] = await pool.execute(
      'INSERT INTO games (name, category, release_date, price) VALUES (?, ?, ?, ?)',
      [name, category, release_date, price]
    );
    res.status(201).json({ id: result.insertId, name, category, release_date, price });
  } catch (err) {
    console.error(err);
    res.status(500).send("Error inserting game");
  }
});

// Get all games
app.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM games');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Error retrieving games");
  }
});

// Update a game
app.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { name, category, release_date, price } = req.body;
  try {
    const [result] = await pool.execute(
      'UPDATE games SET name=?, category=?, release_date=?, price=? WHERE id=?',
      [name, category, release_date, price, id]
    );
    if (result.affectedRows === 0) return res.status(404).send("Game not found");
    res.json({ id, name, category, release_date, price });
  } catch (err) {
    console.error(err);
    res.status(500).send("Error updating game");
  }
});

app.listen(3000, () => console.log("Game Service connected to MySQL on port 3000"));
