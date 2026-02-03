/**
 * Model Selector Component
 * Traceability: FUN-MODEL-SELECT, STK-CONFIG
 */
import { useState, useEffect } from 'react';
import axios from 'axios';
import { ChevronDown } from 'lucide-react';
import config from '../config';

// STK-CONFIG-015: Configuration values replace hardcoded URLs
const API_BASE = config.apiBase;

function ModelSelector({ selectedModel, onSelectModel, disabled }) {
  const [models, setModels] = useState({ base: [], lora: [], merged: [] });
  const [loading, setLoading] = useState(true);
  const [category, setCategory] = useState('base');

  // FUN-MODEL-SELECT-001: Load models on mount
  useEffect(() => {
    loadModels();
  }, []);

  const loadModels = async () => {
    try {
      const response = await axios.get(`${API_BASE}/models`);
      setModels(response.data);
      
      // Auto-select first base model if available
      if (response.data.base.length > 0) {
        onSelectModel(response.data.base[0]);
      }
    } catch (error) {
      console.error('Failed to load models:', error);
    } finally {
      setLoading(false);
    }
  };

  const currentModels = models[category] || [];

  return (
    <div>
      <label className="block text-sm font-medium text-gray-700 mb-2">
        Model <span className="text-red-500">*</span>
      </label>

      {/* FUN-MODEL-SELECT-007: Category tabs */}
      <div className="flex space-x-2 mb-3">
        <button
          onClick={() => setCategory('base')}
          disabled={disabled}
          className={`px-3 py-1 text-sm rounded ${
            category === 'base'
              ? 'bg-blue-600 text-white'
              : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
          } disabled:opacity-50`}
        >
          Base ({models.base.length})
        </button>
        <button
          onClick={() => setCategory('merged')}
          disabled={disabled}
          className={`px-3 py-1 text-sm rounded ${
            category === 'merged'
              ? 'bg-blue-600 text-white'
              : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
          } disabled:opacity-50`}
        >
          Merged ({models.merged.length})
        </button>
        <button
          onClick={() => setCategory('lora')}
          disabled={disabled}
          className={`px-3 py-1 text-sm rounded ${
            category === 'lora'
              ? 'bg-blue-600 text-white'
              : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
          } disabled:opacity-50`}
        >
          LoRA ({models.lora.length})
        </button>
      </div>

      {/* FUN-MODEL-SELECT-010: Model dropdown */}
      <div className="relative">
        <select
          value={selectedModel?.filename || ''}
          onChange={(e) => {
            const model = currentModels.find(m => m.filename === e.target.value);
            onSelectModel(model);
          }}
          disabled={disabled || loading}
          className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 appearance-none pr-10"
        >
          {loading && <option>Loading models...</option>}
          {!loading && currentModels.length === 0 && (
            <option>No {category} models found</option>
          )}
          {!loading && currentModels.map((model) => (
            <option key={model.filename} value={model.filename}>
              {model.display_name}
            </option>
          ))}
        </select>
        <ChevronDown className="absolute right-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
      </div>

      {selectedModel && (
        <p className="mt-2 text-xs text-gray-500">
          {selectedModel.filename}
        </p>
      )}
    </div>
  );
}

export default ModelSelector;
