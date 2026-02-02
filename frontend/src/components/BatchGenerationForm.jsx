/**
 * Batch Generation Form Component
 * Traceability: FUN-BATCH-GEN
 */
import { useState } from 'react';
import GenerationForm from './GenerationForm';

function BatchGenerationForm() {
  const [batchCount, setBatchCount] = useState(4);
  const [seedMode, setSeedMode] = useState('random');

  return (
    <div className="bg-white shadow rounded-lg p-6 mt-6">
      <div className="mb-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Batch Generation Settings</h3>
        
        {/* FUN-BATCH-GEN-002: Batch count */}
        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Batch Count: {batchCount}
          </label>
          <input
            type="range"
            min="2"
            max="20"
            value={batchCount}
            onChange={(e) => setBatchCount(Number(e.target.value))}
            className="w-full"
          />
          <div className="flex justify-between text-xs text-gray-500">
            <span>2</span>
            <span>20</span>
          </div>
        </div>

        {/* FUN-BATCH-GEN-003: Seed mode */}
        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Seed Mode
          </label>
          <select
            value={seedMode}
            onChange={(e) => setSeedMode(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md"
          >
            <option value="random">Random (different seeds)</option>
            <option value="fixed">Fixed (same seed)</option>
            <option value="incremental">Incremental (seed+1 each)</option>
          </select>
        </div>
      </div>

      <div className="border-t border-gray-200 pt-6">
        <p className="text-sm text-gray-600 mb-4">
          Configure base parameters below. {batchCount} images will be generated.
        </p>
        {/* TODO: Integrate with actual batch API endpoint */}
        <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-md">
          <p className="text-sm text-yellow-800">
            Batch generation UI implementation in progress.
            Use single generation tab for now.
          </p>
        </div>
      </div>
    </div>
  );
}

export default BatchGenerationForm;
