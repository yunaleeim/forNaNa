const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { ensureFile, readJson, writeJson } = require('fs-extra');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA = path.join(__dirname, 'data', 'messages.json');

app.use(cors());
app.use(bodyParser.json());
app.use(express.static(__dirname)); // index.html, cheers.json 서빙

async function readMessages(){ try{ return await readJson(DATA); }catch{ return { messages: [] }; } }
async function writeMessages(obj){ await ensureFile(DATA); await writeJson(DATA, obj, { spaces: 2 }); }

app.get('/api/messages', async (_,res)=>{ res.json(await readMessages()); });
app.post('/api/messages', async (req,res)=>{
  const { name, text } = req.body||{};
  if(!name || !text) return res.status(400).json({ error:'name,text required' });
  const data = await readMessages();
  data.messages.push({ name, text, ts: Date.now() });
  await writeMessages(data);
  res.json(data);
});

// (선택) 하루 1문장 서버 응원
app.get('/api/cheer', (_,res)=>{
  const base = ['한 문제 더! 💙','꾸준함이 이긴다 ✨','집중 25분, 휴식 5분 ⏱️','기출은 최고의 스승 📘'];
  res.send(base[new Date().getDate()%base.length]);
});

app.listen(PORT, ()=>console.log(`Server running: http://localhost:${PORT}`));
