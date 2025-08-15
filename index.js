const http = require('http'); 
const port = 3000;
const host = '0.0.0.0';

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello from Terraform + ECS + Docker!\n');
});

server.listen(port, host, () => {
    console.log(`Server running at http://${host}:${port}`);
});
