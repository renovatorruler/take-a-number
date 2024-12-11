# Queue Number System

## Description

# Take a Number - Real-time Queue Management System

A modern, real-time take-a-number system built with GunDB, offering a peer-to-peer, offline-first queuing solution. Perfect for small businesses, clinics, or any venue that needs a simple yet effective queue management system.

## 🚀 Features

### Core Features

- Real-time number synchronization across all devices
- Mobile-first, responsive design
- Offline-first capability
- Persistent state management
- QR code integration (coming soon)

### User Features

- Take a new number with one click
- Clear status indicators (unassigned, waiting, served)
- Mark yourself as served
- View your number history
- Automatic state persistence across sessions

### Technical Features

- Peer-to-peer data synchronization using GunDB
- Local storage support
- Session management
- Real-time updates
- Responsive UI with consistent styling

## Getting Started

1. Install dependencies:

```bash
npm install
```

2. Start the development server:

```bash
npm run dev
```

To open the app in a new browser tab automatically, use:

```bash
npm run dev -- --open
```

## Building for Production

Create a production build:

```bash
npm run build
```

Preview the production build:

```bash
npm run preview
```

## 💻 Usage

### Taking a Number

1. Visit the application URL
2. Click "Take a Number" button
3. Your number will be displayed and synchronized across all connected devices

### Marking as Served

1. When your service is complete, click "Mark as Served"
2. Your status will update, and you'll be able to take a new number if needed

### Viewing History

- Your number history is automatically maintained
- Each entry shows the number, timestamp, and status
- History persists across sessions

## 🔧 Technical Details

### State Management

The application manages three primary states:

- `unassigned`: Initial state, no number taken
- `waiting`: Number assigned, waiting to be served
- `served`: Service complete

### Data Persistence

- User data is stored in GunDB with real-time synchronization
- Local storage is used for user identification
- History is maintained per user across sessions

### Styling

- Consistent button styling with hover effects
- Mobile-first responsive design
- Clear visual status indicators

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🚧 Roadmap

- [ ] QR code integration
- [ ] Multiple queue support
- [ ] Admin interface
- [ ] Queue position estimation
- [ ] SMS notifications
- [ ] Voice announcements
- [ ] Custom themes
- [ ] Analytics dashboard

## ⚠️ Known Issues

- State persistence requires proper GunDB peer configuration
- Initial load may require page refresh in some cases
- Browser compatibility: Tested on modern browsers only

## 📞 Support

For support, please open an issue in the GitHub repository or contact the maintainers.

## 🙏 Acknowledgments

- GunDB team for the amazing peer-to-peer database
- Contributors and early adopters
