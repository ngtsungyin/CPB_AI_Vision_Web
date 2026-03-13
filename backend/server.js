const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Configure Gmail transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER, // Your Gmail
    pass: process.env.EMAIL_PASS  // Your App Password
  }
});

// Test endpoint
app.get('/', (req, res) => {
  res.send('Email backend is running!');
});

// Send OTP endpoint
app.post('/send-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;
    
    console.log(`📧 Sending OTP ${otp} to ${email}`);
    
    const mailOptions = {
      from: `"CPB AI Vision" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: '🔐 Your Admin Login OTP Code',
      html: `
        <!DOCTYPE html>
        <html>
        <body style="font-family: Arial, sans-serif; padding: 20px;">
          <div style="max-width: 600px; margin: 0 auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center;">
              <h1 style="color: white; margin: 0;">CPB AI Vision</h1>
              <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0;">Admin Login Verification</p>
            </div>
            <div style="padding: 40px 30px;">
              <h2 style="color: #333; margin-top: 0;">Your OTP Code</h2>
              <p style="color: #666; margin-bottom: 30px;">Use this code to complete your login:</p>
              <div style="background: #f8f9fa; border: 2px dashed #667eea; border-radius: 10px; padding: 20px; text-align: center;">
                <span style="font-size: 48px; font-weight: bold; letter-spacing: 8px; color: #667eea;">${otp}</span>
              </div>
              <p style="color: #999; font-size: 14px; margin-top: 30px;">This code expires in 10 minutes.</p>
            </div>
          </div>
        </body>
        </html>
      `,
      text: `Your OTP code is: ${otp}. This code expires in 10 minutes.`
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('✅ Email sent:', info.messageId);
    
    res.json({ success: true, messageId: info.messageId });
    
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Backend running on port ${PORT}`);
});