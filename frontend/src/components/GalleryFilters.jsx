/**
 * Gallery Filters Component
 * Traceability: FUN-GALLERY-VIEW-018
 */
import { Search, Calendar } from 'lucide-react';

function GalleryFilters({ filters, onFilterChange, onApply }) {
  return (
    <div className="bg-white shadow rounded-lg p-4 mb-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* Keyword search */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            <Search className="inline h-4 w-4 mr-1" />
            Search Prompt
          </label>
          <input
            type="text"
            value={filters.keyword}
            onChange={(e) => onFilterChange({ ...filters, keyword: e.target.value })}
            placeholder="Enter keywords..."
            className="w-full px-3 py-2 border border-gray-300 rounded-md"
          />
        </div>

        {/* Date from */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            <Calendar className="inline h-4 w-4 mr-1" />
            From Date
          </label>
          <input
            type="date"
            value={filters.dateFrom || ''}
            onChange={(e) => onFilterChange({ ...filters, dateFrom: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-md"
          />
        </div>

        {/* Date to */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            <Calendar className="inline h-4 w-4 mr-1" />
            To Date
          </label>
          <input
            type="date"
            value={filters.dateTo || ''}
            onChange={(e) => onFilterChange({ ...filters, dateTo: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-md"
          />
        </div>
      </div>

      <div className="mt-4 flex space-x-3">
        <button
          onClick={onApply}
          className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
        >
          Apply Filters
        </button>
        <button
          onClick={() => {
            onFilterChange({ dateFrom: null, dateTo: null, keyword: '' });
            onApply();
          }}
          className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
        >
          Clear Filters
        </button>
      </div>
    </div>
  );
}

export default GalleryFilters;
