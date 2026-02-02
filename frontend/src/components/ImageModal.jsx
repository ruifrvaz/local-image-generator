/**
 * Image Modal Component
 * Traceability: FUN-GALLERY-VIEW-021
 */
import { X, Download, Trash2 } from 'lucide-react';

function ImageModal({ image, onClose, onDelete }) {
  const imageUrl = `http://localhost:8000/api/gallery/image/${image.id}`;

  const handleDelete = () => {
    if (confirm('Delete this image permanently?')) {
      onDelete(image.id);
      onClose();
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-75 z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg max-w-6xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b border-gray-200">
          <h3 className="text-lg font-medium text-gray-900">Image Details</h3>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-full"
          >
            <X className="h-5 w-5 text-gray-500" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Image */}
          <div>
            <img
              src={imageUrl}
              alt={image.prompt}
              className="w-full h-auto rounded-lg shadow-lg"
            />
            <div className="flex space-x-3 mt-4">
              <a
                href={imageUrl}
                download
                className="flex-1 px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 flex items-center justify-center"
              >
                <Download className="h-4 w-4 mr-2" />
                Download
              </a>
              <button
                onClick={handleDelete}
                className="flex-1 px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 flex items-center justify-center"
              >
                <Trash2 className="h-4 w-4 mr-2" />
                Delete
              </button>
            </div>
          </div>

          {/* Metadata */}
          <div className="space-y-4">
            <div>
              <h4 className="text-sm font-medium text-gray-700 mb-2">Prompt</h4>
              <p className="text-sm text-gray-900 bg-gray-50 p-3 rounded-md">
                {image.prompt}
              </p>
            </div>

            {image.model && (
              <div>
                <h4 className="text-sm font-medium text-gray-700 mb-2">Model</h4>
                <p className="text-sm text-gray-900">{image.model}</p>
              </div>
            )}

            {image.parameters && (
              <div>
                <h4 className="text-sm font-medium text-gray-700 mb-2">Parameters</h4>
                <dl className="text-sm space-y-1">
                  {image.parameters.steps && (
                    <div className="flex justify-between">
                      <dt className="text-gray-600">Steps:</dt>
                      <dd className="text-gray-900">{image.parameters.steps}</dd>
                    </div>
                  )}
                  {image.parameters.cfg && (
                    <div className="flex justify-between">
                      <dt className="text-gray-600">CFG:</dt>
                      <dd className="text-gray-900">{image.parameters.cfg}</dd>
                    </div>
                  )}
                  {image.seed && (
                    <div className="flex justify-between">
                      <dt className="text-gray-600">Seed:</dt>
                      <dd className="text-gray-900">{image.seed}</dd>
                    </div>
                  )}
                  {image.parameters.resolution && (
                    <div className="flex justify-between">
                      <dt className="text-gray-600">Resolution:</dt>
                      <dd className="text-gray-900">
                        {image.parameters.resolution.width}x{image.parameters.resolution.height}
                      </dd>
                    </div>
                  )}
                </dl>
              </div>
            )}

            {image.timestamp && (
              <div>
                <h4 className="text-sm font-medium text-gray-700 mb-2">Generated</h4>
                <p className="text-sm text-gray-900">
                  {new Date(image.timestamp).toLocaleString()}
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default ImageModal;
