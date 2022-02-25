FROM node:16.14.0 as node-base
FROM ruby:3.1.1

COPY --from=node-base /usr/local /usr/local
COPY --from=node-base /opt /opt

RUN mkdir /app
WORKDIR /app

# Start the main process.
CMD ["bundle", "exec", "rake", "extension"]
