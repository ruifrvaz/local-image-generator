/**
 * Gallery Page - Browse Generated Images
 * Traceability: FUN-GALLERY-VIEW
 */
import { useState, useEffect } from 'react';
import Gallery from '../components/Gallery';
import GalleryFilters from '../components/GalleryFilters';
import GalleryStatistics from '../components/GalleryStatistics';
import axios from 'axios';

const API_BASE = 'http://172.31.243.212:8000/api';

function GalleryPage() {
  const [images, setImages] = useState([]);
  const [statistics, setStatistics] = useState(null);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({
    dateFrom: null,
    dateTo: null,
    keyword: '',
  });

  // FUN-GALLERY-VIEW-001: Load gallery on mount
  useEffect(() => {
    loadGallery();
    loadStatistics();
  }, []);

  const loadGallery = async () => {
    try {
      setLoading(true);
      const params = {};
      if (filters.dateFrom) params.date_from = filters.dateFrom;
      if (filters.dateTo) params.date_to = filters.dateTo;
      if (filters.keyword) params.keyword = filters.keyword;

      const response = await axios.get(`${API_BASE}/gallery`, { params });
      // Backend returns array directly, not wrapped in {images: [...]}
      setImages(Array.isArray(response.data) ? response.data : []);
    } catch (error) {
      console.error('Failed to load gallery:', error);
      setImages([]); // Set empty array on error
    } finally {
      setLoading(false);
    }
  };

  const loadStatistics = async () => {
    try {
      const response = await axios.get(`${API_BASE}/gallery/statistics`);
      setStatistics(response.data);
    } catch (error) {
      console.error('Failed to load statistics:', error);
    }
  };

  const handleFilterChange = (newFilters) => {
    setFilters(newFilters);
  };

  const handleApplyFilters = () => {
    loadGallery();
  };

  const handleDeleteImage = async (imageId) => {
    try {
      await axios.delete(`${API_BASE}/gallery/image/${imageId}`);
      loadGallery(); // Reload gallery
      loadStatistics(); // Update statistics
    } catch (error) {
      console.error('Failed to delete image:', error);
    }
  };

  return (
    <div className="px-4 py-6">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Gallery</h1>
        <p className="mt-2 text-sm text-gray-600">
          Browse and manage your generated images
        </p>
      </div>

      {/* FUN-GALLERY-VIEW-009: Statistics */}
      {statistics && <GalleryStatistics statistics={statistics} />}

      {/* FUN-GALLERY-VIEW-018: Filters */}
      <GalleryFilters
        filters={filters}
        onFilterChange={handleFilterChange}
        onApply={handleApplyFilters}
      />

      {/* FUN-GALLERY-VIEW-003: Grid display */}
      <Gallery
        images={images}
        loading={loading}
        onDeleteImage={handleDeleteImage}
      />
    </div>
  );
}

export default GalleryPage;
