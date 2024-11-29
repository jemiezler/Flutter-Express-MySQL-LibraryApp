const jwt = require('jsonwebtoken');
const { JWT_KEY } = require('../config/config');

exports.generateToken = (payload) => {
    return jwt.sign(payload, JWT_KEY, { expiresIn: '1d' });
};

exports.verifyToken = (token) => {
    try {
        return jwt.verify(token, JWT_KEY);
    } catch (err) {
        throw new Error('Invalid or expired token');
    }
};

exports.decodeToken = (token) => {
    try {
        return jwt.decode(token, { complete: true });
    } catch (err) {
        throw new Error('Unable to decode token');
    }
};