/**
 * Gallery Grid Component
 * Traceability: FUN-GALLERY-VIEW
 */
import { useState } from 'react';
import { Trash2, Eye } from 'lucide-react';
import ImageModal from './ImageModal';

function Gallery({ images, loading, onDeleteImage }) {
  const [selectedImage, setSelectedImage] = useState(null);

  if (loading) {
    return (
      <div className="text-center py-12">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
        <p className="mt-4 text-gray-600">Loading gallery...</p>
      </div>
    );
  }

  if (images.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-600">No images found</p>
        <p className="text-sm text-gray-500 mt-2">Generate some images to see them here</p>
      </div>
    );
  }

  return (
    <>
      {/* FUN-GALLERY-VIEW-003: Grid layout */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {images.map((image) => (
          <div
            key={image.id}
            className="bg-white rounded-lg shadow hover:shadow-lg transition-shadow"
          >
            {/* FUN-GALLERY-VIEW-004: Thumbnail display */}
            <div className="relative group">
              <img
                src={image.thumbnail || `http://localhost:8000/api/gallery/image/${image.id}`}
                alt={image.prompt.substring(0, 50)}
                className="w-full h-64 object-cover rounded-t-lg cursor-pointer"
                onClick={() => setSelectedImage(image)}
              />
              
              {/* Hover overlay */}
              <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-30 transition-opacity rounded-t-lg flex items-center justify-center opacity-0 group-hover:opacity-100">
                <button
                  onClick={() => setSelectedImage(image)}
                  className="p-2 bg-white rounded-full mr-2"
                  title="View"
                >
                  <Eye className="h-5 w-5 text-gray-700" />
                </button>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    if (confirm('Delete this image?')) {
                      onDeleteImage(image.id);
                    }
                  }}
                  className="p-2 bg-white rounded-full"
                  title="Delete"
                >
                  <Trash2 className="h-5 w-5 text-red-600" />
                </button>
              </div>
            </div>

            {/* FUN-GALLERY-VIEW-005: Metadata preview */}
            <div className="p-3">
              <p className="text-sm text-gray-700 line-clamp-2 mb-2">
                {image.prompt}
              </p>
              <div className="text-xs text-gray-500 space-y-1">
                {image.model && (
                  <p className="truncate">
                    <span className="font-medium">Model:</span> {image.model}
                  </p>
                )}
                {image.timestamp && (
                  <p>
                    <span className="font-medium">Date:</span>{' '}
                    {new Date(image.timestamp).toLocaleDateString()}
                  </p>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* FUN-GALLERY-VIEW-021: Image modal */}
      {selectedImage && (
        <ImageModal
          image={selectedImage}
          onClose={() => setSelectedImage(null)}
          onDelete={onDeleteImage}
        />
      )}
    </>
  );
}

export default Gallery;
