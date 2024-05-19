FROM node:19.5.0

WORKDIR /app

COPY . .

RUN npm install

RUN npm run build

CMD ["npm", "run", "dev"]
