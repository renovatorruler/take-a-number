import express from 'express';
import Gun from 'gun';

const app = express();
const port = process.env.PORT || 8765;

app.use(Gun.serve);

const server = app.listen(port, () => {
    console.log(`GunDB server running on port ${port}`);
});

// Create a Gun instance using the server
const gun = Gun({
    web: server,
    file: 'data'  // This will store data in a 'data' directory
});