// analytics-service/server.js
const express = require('express');
const { createClient } = require('@clickhouse/client');
const AWS = require('aws-sdk');  // <-- Added AWS SDK
const app = express();
app.use(express.json());

// Initialize ClickHouse client
const clickhouse = createClient({
  host: process.env.CLICKHOUSE_URL || 'http://clickhouse:8123',
  username: process.env.CLICKHOUSE_USER || 'default',
  password: process.env.CLICKHOUSE_PASSWORD || '',
  database: process.env.CLICKHOUSE_DB || 'analytics'
});

// Initialize AWS S3 client
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'ap-south-1'
});

// GET endpoint: fetch data from ClickHouse
app.get('/', async (req, res) => {
  try {
    const result = await clickhouse.query({
      query: `SELECT user_id, event_type, page, duration, timestamp 
              FROM analytics.analytics_events 
              ORDER BY timestamp DESC LIMIT 20`,
      format: 'JSONEachRow'
    });

    const rows = await result.json();
    console.log(`✅ Retrieved ${rows.length} analytics events from ClickHouse`);
    res.json(rows.length ? rows : [{ message: "No analytics data found" }]);
  } catch (err) {
    console.error("❌ Error fetching events from ClickHouse:", err);
    res.status(500).json({ error: "Failed to fetch events from ClickHouse" });
  }
});

// POST endpoint: insert events
app.post('/', async (req, res) => {
  const { userId, eventType, page, duration } = req.body;

  if (!userId || !eventType || !page) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    await clickhouse.insert({
      table: 'analytics.analytics_events',
      values: [{
        user_id: userId,
        event_type: eventType,
        page: page,
        duration: duration || 0
      }],
      format: 'JSONEachRow'
    });

    console.log(`✅ Inserted event: ${eventType} on ${page} by ${userId}`);
    res.status(201).json({ message: "Event saved successfully" });
  } catch (err) {
    console.error("❌ Error inserting event:", err);
    res.status(500).json({ error: "Failed to save event" });
  }
});

// NEW: Export endpoint to S3
app.get('/export', async (req, res) => {
  try {
    const result = await clickhouse.query({
      query: `SELECT user_id, event_type, page, duration, timestamp 
              FROM analytics.analytics_events`,
      format: 'CSVWithNames'
    });

    const csv = await result.text();

    const params = {
      Bucket: process.env.S3_BUCKET || 'lugx-game-analytics-data',
      Key: 'analytics_data.csv',
      Body: csv,
      ContentType: 'text/csv'
    };

    await s3.putObject(params).promise();
    console.log("✅ Exported analytics_data.csv to S3");
    res.json({ message: "✅ Exported analytics_data.csv to S3" });
  } catch (err) {
    console.error("❌ Export failed:", err);
    res.status(500).json({ error: "Export failed" });
  }
});

app.listen(3002, () => console.log("Analytics Service running on port 3002"));
