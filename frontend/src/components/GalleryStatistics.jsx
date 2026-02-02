/**
 * Gallery Statistics Component
 * Traceability: FUN-GALLERY-VIEW-009
 */
import { Image, Calendar, HardDrive } from 'lucide-react';

function GalleryStatistics({ statistics }) {
  const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return `${(bytes / Math.pow(k, i)).toFixed(2)} ${sizes[i]}`;
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
      <div className="bg-white shadow rounded-lg p-4">
        <div className="flex items-center">
          <div className="p-3 bg-blue-100 rounded-lg">
            <Image className="h-6 w-6 text-blue-600" />
          </div>
          <div className="ml-4">
            <p className="text-sm text-gray-600">Total Images</p>
            <p className="text-2xl font-bold text-gray-900">{statistics.total_images}</p>
          </div>
        </div>
      </div>

      <div className="bg-white shadow rounded-lg p-4">
        <div className="flex items-center">
          <div className="p-3 bg-green-100 rounded-lg">
            <Calendar className="h-6 w-6 text-green-600" />
          </div>
          <div className="ml-4">
            <p className="text-sm text-gray-600">Generated Today</p>
            <p className="text-2xl font-bold text-gray-900">{statistics.today_count || 0}</p>
          </div>
        </div>
      </div>

      <div className="bg-white shadow rounded-lg p-4">
        <div className="flex items-center">
          <div className="p-3 bg-purple-100 rounded-lg">
            <HardDrive className="h-6 w-6 text-purple-600" />
          </div>
          <div className="ml-4">
            <p className="text-sm text-gray-600">Total Storage</p>
            <p className="text-2xl font-bold text-gray-900">
              {formatFileSize(statistics.total_size_bytes)}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

export default GalleryStatistics;
