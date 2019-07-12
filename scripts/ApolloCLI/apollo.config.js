require('dotenv').config()

module.exports = {
    client: {
        service: {
            name: 'Ostelco GraphQL API',
            url: process.env.URL,
            headers: {
                authorization: 'Bearer ' + process.env.TOKEN
            },
        }
    }
};
