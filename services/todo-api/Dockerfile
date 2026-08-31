FROM node:22-bookworm-slim
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY src ./src
COPY database ./database
EXPOSE 8080
USER node
CMD ["node", "src/server.js"]
