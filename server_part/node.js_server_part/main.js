const http = require('http');
const express = require('express');
const socketIo = require('socket.io');


const app = express();
const server = http.createServer(app);
const io = socketIo(server);


const port = 3000;


// 用于存储连接的客户端信息的对象
let connectedClients = {};
let playerCount = 0;


io.on('connection', (socket) => {
  const role = socket.handshake.query.role;
  console.log(role);
  connectedClients[socket.id] = { role, needsReset: false };
 
  console.log('A user connected with role:', role);


  // 根据角色发送不同的欢迎消息
  if (role === "host") {
    console.log('A host connected');
    socket.emit('message', {
      success: true,
      message: "Welcome, host!"
    });
  } else if (role === "player") {
    playerCount++;
    let update = playerCount.toString();
    console.log('A player connected');
    console.log("Total players connected:", playerCount);
    io.to(Object.keys(connectedClients).find(socketId => connectedClients[socketId].role === 'host')).emit('countUpdate', update);
    socket.emit('message', {
      success: true,
      message: "Welcome, player!"
    });
  } else {
    console.log('Unknown role connected');
    socket.emit('message', {
      success: false,
      message: "Unknown role!"
    });
  }
  socket.on('reset_server', () => {
    const playerClients = Object.keys(connectedClients).filter(socketId => connectedClients[socketId].role === 'player');
    playerClients.forEach(playerSocketId => {
      io.to(playerSocketId).emit('reset');
    });
    io.to(Object.keys(connectedClients).find(socketId => connectedClients[socketId].role === 'host')).emit('reset');
    Object.keys(connectedClients).forEach(socketId => {
      delete connectedClients[socketId];
    });
  });

  socket.on('disconnect', () => {
    console.log('User disconnected');
    if (role === "player") {
      playerCount--;
      console.log('Player disconnected');
    }
    delete connectedClients[socket.id];
  });

  socket.on('startGame', () => {
    console.log('Received start game signal from host');
    const playerClients = Object.keys(connectedClients).filter(socketId => connectedClients[socketId].role === 'player');
    playerClients.forEach(playerSocketId => {
      io.to(playerSocketId).emit('startGame');
    });
  });
  socket.on('BingoNumber', (data) => {
    console.log(`Received start game signal from host:${data}`);
    const playerClients = Object.keys(connectedClients).filter(socketId => connectedClients[socketId].role === 'player');
    playerClients.forEach(playerSocketId => {
      io.to(playerSocketId).emit('BingoNumber', data);
    });
  });
  socket.on('player_has_bingo', (data) => {
    console.log(`${data}`);
    const playerClients = Object.keys(connectedClients).filter(socketId => connectedClients[socketId].role === 'player');
    playerClients.forEach(playerSocketId => {
      io.to(playerSocketId).emit('end_game', data);
    });
    io.to(Object.keys(connectedClients).find(socketId => connectedClients[socketId].role === 'host')).emit('end_game', data);
  });
});


server.listen(port, () => {
  console.log(`Server is listening on port ${port}`);
});