# Deployment Guide - Parkinson's Monitor Website

This guide will help you deploy your website so it can be accessed from anywhere on the internet.

## Quick Deploy Options

### Option 1: Netlify (Recommended - Easiest)

**Steps:**
1. Go to [netlify.com](https://www.netlify.com) and sign up/login (free)
2. Drag and drop your entire project folder onto the Netlify dashboard
   - OR connect your GitHub repository
   - OR use Netlify CLI: `npx netlify-cli deploy --prod --dir=.`
3. Your site will be live instantly with a URL like: `https://your-site-name.netlify.app`
4. You can customize the domain name in Netlify settings

**Advantages:**
- Free tier available
- Automatic HTTPS
- Easy custom domain setup
- Continuous deployment from GitHub (optional)

---

### Option 2: Vercel (Fast & Modern)

**Steps:**
1. Go to [vercel.com](https://www.vercel.com) and sign up/login (free)
2. Click "New Project"
3. Import your GitHub repository OR drag and drop your folder
4. Click "Deploy"
5. Your site will be live with a URL like: `https://your-site-name.vercel.app`

**Advantages:**
- Very fast global CDN
- Free tier available
- Automatic HTTPS
- Easy custom domain

---

### Option 3: GitHub Pages (Free with GitHub)

**Steps:**
1. Create a GitHub account if you don't have one
2. Create a new repository on GitHub
3. Upload all your files to the repository
4. Go to repository Settings → Pages
5. Under "Source", select "Deploy from a branch"
6. Choose `main` branch and `/ (root)` folder
7. Click "Save"
8. Your site will be live at: `https://your-username.github.io/repository-name`

**Note:** If you use GitHub Pages, make sure all paths in your HTML files are relative (they already are!).

**Advantages:**
- Completely free
- Integrated with GitHub
- Custom domain support

---

### Option 4: Cloudflare Pages (Free)

**Steps:**
1. Go to [pages.cloudflare.com](https://pages.cloudflare.com) and sign up
2. Connect your GitHub repository OR upload files directly
3. Configure build settings:
   - Build command: (leave empty)
   - Build output directory: `.` (root)
4. Click "Save and Deploy"
5. Your site will be live with a URL like: `https://your-site.pages.dev`

**Advantages:**
- Free tier available
- Fast global CDN
- Automatic HTTPS

---

## Using Command Line (Advanced)

### Netlify CLI
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Deploy
netlify deploy --prod --dir=.
```

### Vercel CLI
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod
```

---

## Custom Domain Setup

All platforms support custom domains:

1. **Netlify:** Settings → Domain management → Add custom domain
2. **Vercel:** Project Settings → Domains → Add domain
3. **GitHub Pages:** Repository Settings → Pages → Custom domain
4. **Cloudflare Pages:** Custom domains → Add domain

You'll need to:
- Purchase a domain (from Namecheap, GoDaddy, etc.)
- Update DNS records as instructed by your hosting platform

---

## Important Notes

### WebSocket Connections
⚠️ **Note:** Your ESP32 WebSocket connections (`ws://192.168.4.1:81`) will only work on your local network. For remote access, you'll need:
- A VPN connection to your local network, OR
- A reverse proxy/tunnel service (like ngrok, Cloudflare Tunnel, or Tailscale), OR
- Host your ESP32 on a public server with a WebSocket endpoint

### HTTPS Requirements
- BLE (Bluetooth) connections require HTTPS or localhost
- Once deployed, your site will have HTTPS automatically
- Make sure your ESP32 WebSocket URL uses `wss://` (secure WebSocket) if connecting from the deployed site

### Demo Mode
The demo mode will work perfectly on the deployed site - users can test the dashboard without connecting to an ESP32.

---

## Testing Your Deployment

After deploying:
1. Visit your live URL
2. Test all pages (Home, Dashboard, About, Contact)
3. Try the Demo Mode on the Dashboard
4. Test theme toggle
5. Verify all assets (CSS, JS, images) load correctly

---

## Need Help?

- **Netlify Docs:** https://docs.netlify.com
- **Vercel Docs:** https://vercel.com/docs
- **GitHub Pages Docs:** https://docs.github.com/en/pages

---

**Your website is ready to deploy! Choose any option above and your site will be live in minutes.** 🚀

