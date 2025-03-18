<template>
  <div class="game-container" ref="gameContainer" :class="{ active: isGameActive }">
    <div class="game-info" v-if="!isGameActive && !gameOver">
      <h1>Flappy Bird</h1>
      <p>苹果风格设计 - 简单版</p>
      <button class="start-button" @click="startGame">开始游戏</button>
      <div class="instructions">
        <p>手机：点击屏幕让小鸟飞翔</p>
        <p>电脑：按空格键让小鸟飞翔</p>
      </div>
    </div>
    
    <div class="game-over" v-if="gameOver">
      <h2>游戏结束</h2>
      <p>您的得分：{{ score }}</p>
      <p>最高分：{{ highScore }}</p>
      <button class="restart-button" @click="resetGame">再来一次</button>
    </div>
    
    <div class="game-canvas" ref="gameCanvas" v-show="isGameActive || gameOver">
      <div class="bird" :style="birdStyle" ref="bird"></div>
      <div v-for="(pipe, index) in pipes" :key="index" class="pipe" :style="pipeStyle(pipe)">
        <div class="pipe-top"></div>
        <div class="pipe-gap"></div>
        <div class="pipe-bottom"></div>
      </div>
      <div class="ground"></div>
      <div class="score-display">{{ score }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FlappyBird',
  data() {
    return {
      isGameActive: false,
      gameOver: false,
      score: 0,
      highScore: 0,
      
      // 鸟的属性
      birdPosition: 50,
      birdVelocity: 0,
      gravity: 0.3,
      jumpStrength: -6,
      
      // 管道属性
      pipes: [],
      pipeWidth: 60,
      pipeGap: 150,
      pipeDistance: 300,
      pipeSpeed: 2,
      
      // 游戏循环
      gameInterval: null,
      
      // 设备信息
      isMobile: false
    };
  },
  computed: {
    birdStyle() {
      return {
        top: `${this.birdPosition}px`,
        transform: `rotate(${this.birdVelocity * 3}deg)`
      };
    }
  },
  mounted() {
    // 检测设备类型
    this.isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    
    // 加载最高分
    this.highScore = localStorage.getItem('flappyBirdHighScore') || 0;
    
    // 添加键盘事件监听器（针对桌面设备）
    if (!this.isMobile) {
      window.addEventListener('keydown', this.handleKeydown);
    }
    
    // 添加触摸事件监听器（针对移动设备）
    this.$refs.gameContainer.addEventListener('click', this.handleJump);
    
    // 设置游戏容器大小
    this.setGameSize();
    window.addEventListener('resize', this.setGameSize);
  },
  beforeUnmount() {
    // 移除事件监听器
    window.removeEventListener('keydown', this.handleKeydown);
    window.removeEventListener('resize', this.setGameSize);
    if (this.$refs.gameContainer) {
      this.$refs.gameContainer.removeEventListener('click', this.handleJump);
    }
    this.stopGame();
  },
  methods: {
    setGameSize() {
      const container = this.$refs.gameContainer;
      const width = Math.min(window.innerWidth - 20, 400);
      const height = Math.min(window.innerHeight - 20, 600);
      
      container.style.width = `${width}px`;
      container.style.height = `${height}px`;
    },
    startGame() {
      this.isGameActive = true;
      this.gameOver = false;
      this.score = 0;
      this.birdPosition = 50;
      this.birdVelocity = 0;
      this.pipes = [];
      
      // 添加第一个管道
      this.addPipe();
      
      // 启动游戏循环
      this.gameInterval = setInterval(this.gameLoop, 16);
    },
    stopGame() {
      clearInterval(this.gameInterval);
      this.gameInterval = null;
      this.isGameActive = false;
      this.gameOver = true;
      
      // 更新最高分
      if (this.score > this.highScore) {
        this.highScore = this.score;
        localStorage.setItem('flappyBirdHighScore', this.highScore);
      }
    },
    resetGame() {
      this.gameOver = false;
      this.startGame();
    },
    gameLoop() {
      if (!this.isGameActive) return;
      
      // 更新鸟的位置
      this.birdVelocity += this.gravity;
      this.birdPosition += this.birdVelocity;
      
      // 检测碰撞
      this.checkCollisions();
      
      // 更新管道位置
      this.updatePipes();
      
      // 检查是否需要添加新管道
      const lastPipe = this.pipes[this.pipes.length - 1];
      if (lastPipe && this.$refs.gameCanvas.clientWidth - (lastPipe.position + this.pipeWidth) > this.pipeDistance) {
        this.addPipe();
      }
      
      // 清理离开屏幕的管道
      this.cleanPipes();
    },
    addPipe() {
      const canvasHeight = this.$refs.gameCanvas.clientHeight;
      const groundHeight = 50;
      const availableHeight = canvasHeight - groundHeight;
      
      // 随机确定管道的顶部高度
      const minHeight = 50;
      const maxHeight = availableHeight - this.pipeGap - minHeight;
      const topHeight = Math.floor(Math.random() * (maxHeight - minHeight) + minHeight);
      
      this.pipes.push({
        position: this.$refs.gameCanvas.clientWidth,
        topHeight,
        passed: false
      });
    },
    updatePipes() {
      this.pipes.forEach(pipe => {
        pipe.position -= this.pipeSpeed;
        
        // 检查是否通过了管道（得分）
        const birdRight = 80; // 小鸟右侧的位置
        if (!pipe.passed && pipe.position + this.pipeWidth < birdRight) {
          pipe.passed = true;
          this.score++;
          // 每得10分增加一点难度
          if (this.score % 10 === 0 && this.score > 0) {
            this.pipeSpeed += 0.2;
          }
        }
      });
    },
    cleanPipes() {
      this.pipes = this.pipes.filter(pipe => pipe.position > -this.pipeWidth);
    },
    checkCollisions() {
      const canvasHeight = this.$refs.gameCanvas.clientHeight;
      const birdSize = 30;
      const groundHeight = 50;
      
      // 碰到地面
      if (this.birdPosition + birdSize > canvasHeight - groundHeight) {
        this.stopGame();
        return;
      }
      
      // 碰到顶部
      if (this.birdPosition < 0) {
        this.birdPosition = 0;
        this.birdVelocity = 0;
      }
      
      // 检查管道碰撞
      const birdLeft = 50; // 小鸟左侧的位置
      const birdRight = birdLeft + birdSize;
      const birdTop = this.birdPosition;
      const birdBottom = this.birdPosition + birdSize;
      
      for (const pipe of this.pipes) {
        const pipeLeft = pipe.position;
        const pipeRight = pipe.position + this.pipeWidth;
        
        // 水平碰撞检测
        if (birdRight > pipeLeft && birdLeft < pipeRight) {
          // 垂直碰撞检测
          if (birdTop < pipe.topHeight || birdBottom > pipe.topHeight + this.pipeGap) {
            this.stopGame();
            return;
          }
        }
      }
    },
    handleKeydown(event) {
      if (event.code === 'Space') {
        event.preventDefault();
        this.handleJump();
      }
    },
    handleJump() {
      if (!this.isGameActive && !this.gameOver) {
        this.startGame();
        return;
      }
      
      if (this.isGameActive) {
        this.birdVelocity = this.jumpStrength;
      }
    },
    pipeStyle(pipe) {
      return {
        left: `${pipe.position}px`,
        '--top-height': `${pipe.topHeight}px`,
        '--gap-height': `${this.pipeGap}px`
      };
    }
  }
};
</script>

<style scoped>
.game-container {
  position: relative;
  width: 400px;
  height: 600px;
  margin: 0 auto;
  overflow: hidden;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  background: linear-gradient(to bottom, #87CEEB, #E0F7FA);
  touch-action: manipulation;
}

.game-info {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
  width: 90%;
  z-index: 10;
}

.game-info h1 {
  color: #333;
  font-size: 2.5rem;
  margin-bottom: 10px;
  font-weight: bold;
}

.game-info p {
  color: #555;
  margin-bottom: 20px;
  font-size: 1.2rem;
}

.start-button, .restart-button {
  background: #FF6B6B;
  color: white;
  border: none;
  padding: 12px 30px;
  font-size: 1.2rem;
  border-radius: 25px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 5px 15px rgba(255, 107, 107, 0.4);
}

.start-button:hover, .restart-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 7px 20px rgba(255, 107, 107, 0.6);
}

.instructions {
  margin-top: 20px;
  padding: 15px;
  background: rgba(255, 255, 255, 0.7);
  border-radius: 15px;
}

.instructions p {
  margin: 8px 0;
  font-size: 0.9rem;
  color: #666;
}

.game-over {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(255, 255, 255, 0.9);
  padding: 20px;
  border-radius: 15px;
  text-align: center;
  z-index: 10;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.game-over h2 {
  color: #FF6B6B;
  margin-bottom: 15px;
  font-size: 1.8rem;
}

.game-canvas {
  position: relative;
  width: 100%;
  height: 100%;
}

.bird {
  position: absolute;
  left: 50px;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background-color: #FFDE59;
  z-index: 5;
  transition: transform 0.1s;
}

.bird::before {
  content: '';
  position: absolute;
  top: 5px;
  right: 2px;
  width: 10px;
  height: 10px;
  background-color: white;
  border-radius: 50%;
  z-index: 6;
}

.bird::after {
  content: '';
  position: absolute;
  top: 7px;
  right: 4px;
  width: 4px;
  height: 4px;
  background-color: black;
  border-radius: 50%;
  z-index: 7;
}

.pipe {
  position: absolute;
  width: 60px;
  height: 100%;
  z-index: 3;
}

.pipe-top {
  position: absolute;
  top: 0;
  width: 100%;
  height: var(--top-height);
  background-color: #4CAF50;
  border-radius: 0 0 5px 5px;
}

.pipe-bottom {
  position: absolute;
  top: calc(var(--top-height) + var(--gap-height));
  width: 100%;
  bottom: 0;
  background-color: #4CAF50;
  border-radius: 5px 5px 0 0;
}

.ground {
  position: absolute;
  bottom: 0;
  width: 100%;
  height: 50px;
  background-color: #8D6E63;
  z-index: 4;
}

.score-display {
  position: absolute;
  top: 20px;
  left: 0;
  width: 100%;
  text-align: center;
  font-size: 40px;
  font-weight: bold;
  color: white;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
  z-index: 8;
}

@media (max-width: 480px) {
  .game-container {
    width: calc(100vw - 20px);
    height: calc(100vh - 100px);
    max-height: 80vh;
  }
  
  .game-info h1 {
    font-size: 2rem;
  }
  
  .start-button, .restart-button {
    padding: 10px 25px;
    font-size: 1rem;
  }
}
</style> 