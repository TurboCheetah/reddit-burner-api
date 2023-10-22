FROM node:21-alpine AS builder
WORKDIR /app
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/ .yarn/
RUN yarn install --immutable
COPY . .
RUN yarn build

FROM node:21-alpine AS production-dependencies

WORKDIR /app
COPY --from=builder /app/package.json /app/yarn.lock /app/.yarnrc.yml ./
COPY --from=builder /app/.yarn /app/.yarn/
RUN yarn workspaces focus --all --production

FROM gcr.io/distroless/nodejs:18 as runner
WORKDIR /app
USER 1000
COPY --from=production-dependencies /app .
COPY --from=builder /app/dist dist
ENV NODE_ENV production
EXPOSE 3000
CMD ["dist/index.js"]
