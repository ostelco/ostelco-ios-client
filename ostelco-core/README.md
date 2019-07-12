# Getting Started

This is a draft of how we work with apollo cli, the installation process should be improved and we should possibly move the logic regarding this to a separate folder.
The instructions should also be updated to multiple environments, currently it is only configured for development, not production.

## Apollo CLI

[Apollo CLI](https://github.com/apollographql/apollo-tooling) brings together your GraphQL clients and servers with tools for validating your schema, linting your operations for compatibility with your server, and generating static types for improved client-side type safety.

- You will need to visit the documentation and follow the installation instructions to install Apollo CLI globally
- You will also need to install dotenv
```
npm install dotenv
```
- As well as setup a .env file with corresponding values
```
echo -e "TOKEN=\"...\"\nURL=\"...\"" > .env
```

Here are a few things we are handling with Apollo CLI:

### GraphQL schema

- Download latest graphQL schema from server
```
apollo client:download-schema
```

