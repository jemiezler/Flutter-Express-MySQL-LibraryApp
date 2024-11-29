const swaggerJsdoc = require('swagger-jsdoc');

const swaggerOptions = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'Library Management System API',
            version: '1.0.0',
            description: 'API documentation for the Library Management System',
        },
        servers: [
            {
                url: 'http://localhost:5000', // Update to your production URL
                description: 'Development server',
            },
        ],
    },
    apis: ['./routes/*.js'], // Path to the API route files
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);

module.exports = swaggerSpec;
