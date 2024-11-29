const { verifyToken } = require('../utils/jwtUtils');

exports.verifyUser = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
        return res.status(400).json({ message: 'No token provided' });
    }

    try {
        const decoded = verifyToken(token);
        // if (decoded.role !== 'borrower') {
        //     return res.status(403).json({ message: 'Forbidden: Unauthorized role' });
        // }
        req.user = decoded; // Attach decoded token payload to the request object
        next();
    } catch (err) {
        return res.status(401).json({ message: err.message });
    }
};

exports.verifyLender = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
        return res.status(400).json({ message: 'No token provided' });
    }

    try {
        const decoded = verifyToken(token);
        if (decoded.role !== 'lender') {
            return res.status(403).json({ message: 'Forbidden: Unauthorized role' });
        }
        req.user = decoded;
        next();
    } catch (err) {
        return res.status(401).json({ message: err.message });
    }
};

exports.checkRole = (requiredRole) => {
    return (req, res, next) => {
        const token = req.headers.authorization?.split(' ')[1];
        if (!token) {
            return res.status(400).json({ message: 'No token provided' });
        }

        try {
            const decoded = verifyToken(token);
            if (decoded.role !== requiredRole) {
                return res.status(403).json({ message: 'Forbidden: Unauthorized role' });
            }
            req.user = decoded; // Attach decoded payload to request
            next();
        } catch (err) {
            return res.status(401).json({ message: err.message });
        }
    };
};