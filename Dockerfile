# # Install dependencies
# FROM node:20-alpine

# # Create app directory
# WORKDIR /app

# # Install app dependencies
# COPY package*.json ./
# RUN npm install

# # Copy app source
# COPY . .

# # Build the Next.js app
# RUN npm run build

# # Expose port
# EXPOSE 3000

# # Start app
# CMD ["npm", "run", "dev"]


# Install dependencies
FROM node:18-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# Build app
FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=deps /app ./
COPY . .
RUN npm run build

# Run app
FROM node:18-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["npm", "start"]
