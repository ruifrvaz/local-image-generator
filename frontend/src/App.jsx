/**
 * Main Application Component
 * Traceability: STK-FRONTEND, FUN-GEN-REQUEST, FUN-GALLERY-VIEW
 */
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import HomePage from './pages/HomePage';
import GalleryPage from './pages/GalleryPage';

function App() {
  return (
    <Router>
      <div className="min-h-screen bg-gray-50">
        {/* STK-FRONTEND-008: Navigation bar */}
        <nav className="bg-white shadow-sm border-b border-gray-200">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between h-16">
              <div className="flex space-x-8">
                <Link
                  to="/"
                  className="inline-flex items-center px-1 pt-1 border-b-2 border-transparent hover:border-gray-300 text-sm font-medium text-gray-900"
                >
                  Generate
                </Link>
                <Link
                  to="/gallery"
                  className="inline-flex items-center px-1 pt-1 border-b-2 border-transparent hover:border-gray-300 text-sm font-medium text-gray-900"
                >
                  Gallery
                </Link>
              </div>
            </div>
          </div>
        </nav>

        {/* FUN-GEN-REQUEST, FUN-GALLERY-VIEW: Route content */}
        <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/gallery" element={<GalleryPage />} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;

