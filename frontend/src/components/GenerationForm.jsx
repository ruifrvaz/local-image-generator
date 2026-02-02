/**
 * Generation Form Component
 * Traceability: FUN-GEN-REQUEST
 */
import { useState, useEffect } from 'react';
import axios from 'axios';
import ModelSelector from './ModelSelector';
import GeneratedImage from './GeneratedImage';
import { Loader2 } from 'lucide-react';

const API_BASE = 'http://localhost:8000/api';

// FUN-GEN-REQUEST-002: Generation states
const STATE = {
  IDLE: 'idle',
  VALIDATING: 'validating',
  SUBMITTING: 'submitting',
  QUEUED: 'queued',
  PROCESSING: 'processing',
  COMPLETED: 'completed',
  ERROR: 'error'
};

function GenerationForm() {
  // Form state
  const [prompt, setPrompt] = useState('');
  const [selectedModel, setSelectedModel] = useState(null);
  const [steps, setSteps] = useState(20);
  const [cfg, setCfg] = useState(7.0);
  const [seed, setSeed] = useState(-1);
  const [resolution, setResolution] = useState('1024x1024');

  // Generation state
  const [generationState, setGenerationState] = useState(STATE.IDLE);
  const [requestId, setRequestId] = useState(null);
  const [generatedImage, setGeneratedImage] = useState(null);
  const [errorMessage, setErrorMessage] = useState('');

  // FUN-GEN-REQUEST-003: Validate prompt on input
  const validatePrompt = (text) => {
    if (!text || text.trim().length === 0) {
      return 'Prompt is required';
    }
    if (text.length < 3) {
      return 'Prompt must be at least 3 characters';
    }
    if (text.length > 1000) {
      return 'Prompt must not exceed 1000 characters';
    }
    return null;
  };

  const promptError = validatePrompt(prompt);
  const canGenerate = !promptError && selectedModel && generationState === STATE.IDLE;

  // FUN-GEN-REQUEST-008: Submit generation request
  const handleGenerate = async () => {
    if (!canGenerate) return;

    try {
      setGenerationState(STATE.VALIDATING);
      setErrorMessage('');

      const [width, height] = resolution.split('x').map(Number);

      const payload = {
        prompt: prompt.trim(),
        model: selectedModel.filename,
        steps,
        cfg,
        seed,
        resolution: { width, height }
      };

      setGenerationState(STATE.SUBMITTING);
      const response = await axios.post(`${API_BASE}/generate`, payload);
      
      // FUN-GEN-REQUEST-009: Store request ID
      const { request_id } = response.data;
      setRequestId(request_id);
      setGenerationState(STATE.QUEUED);

      // Start polling for status
      pollGenerationStatus(request_id);
    } catch (error) {
      setGenerationState(STATE.ERROR);
      setErrorMessage(error.response?.data?.detail || 'Failed to submit generation request');
    }
  };

  // FUN-GEN-REQUEST-011: Poll generation status
  const pollGenerationStatus = async (reqId) => {
    const pollInterval = setInterval(async () => {
      try {
        const response = await axios.get(`${API_BASE}/generate/status/${reqId}`);
        const { status, image_url, error } = response.data;

        if (status === 'queued') {
          setGenerationState(STATE.QUEUED);
        } else if (status === 'processing') {
          setGenerationState(STATE.PROCESSING);
        } else if (status === 'completed') {
          clearInterval(pollInterval);
          setGenerationState(STATE.COMPLETED);
          setGeneratedImage(image_url);
        } else if (status === 'error') {
          clearInterval(pollInterval);
          setGenerationState(STATE.ERROR);
          setErrorMessage(error || 'Generation failed');
        }
      } catch (error) {
        clearInterval(pollInterval);
        setGenerationState(STATE.ERROR);
        setErrorMessage('Failed to check generation status');
      }
    }, 2000); // Poll every 2 seconds

    // Timeout after 5 minutes
    setTimeout(() => {
      clearInterval(pollInterval);
      if (generationState !== STATE.COMPLETED) {
        setGenerationState(STATE.ERROR);
        setErrorMessage('Generation timed out');
      }
    }, 300000);
  };

  const handleReset = () => {
    setGenerationState(STATE.IDLE);
    setRequestId(null);
    setGeneratedImage(null);
    setErrorMessage('');
  };

  return (
    <div className="bg-white shadow rounded-lg p-6 mt-6">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Left: Form */}
        <div className="space-y-6">
          {/* FUN-GEN-REQUEST-006: Prompt input */}
          <div>
            <label htmlFor="prompt" className="block text-sm font-medium text-gray-700 mb-2">
              Prompt <span className="text-red-500">*</span>
            </label>
            <textarea
              id="prompt"
              value={prompt}
              onChange={(e) => setPrompt(e.target.value)}
              disabled={generationState !== STATE.IDLE}
              rows={4}
              className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
              placeholder="Describe the image you want to generate..."
            />
            {promptError && prompt.length > 0 && (
              <p className="mt-1 text-sm text-red-600">{promptError}</p>
            )}
            <p className="mt-1 text-sm text-gray-500">{prompt.length} / 1000 characters</p>
          </div>

          {/* FUN-MODEL-SELECT-010: Model selector */}
          <ModelSelector
            selectedModel={selectedModel}
            onSelectModel={setSelectedModel}
            disabled={generationState !== STATE.IDLE}
          />

          {/* FUN-GEN-REQUEST-013: Steps input */}
          <div>
            <label htmlFor="steps" className="block text-sm font-medium text-gray-700 mb-2">
              Steps: {steps}
            </label>
            <input
              id="steps"
              type="range"
              min="10"
              max="50"
              value={steps}
              onChange={(e) => setSteps(Number(e.target.value))}
              disabled={generationState !== STATE.IDLE}
              className="w-full"
            />
            <div className="flex justify-between text-xs text-gray-500">
              <span>10</span>
              <span>50</span>
            </div>
          </div>

          {/* FUN-GEN-REQUEST-013: CFG input */}
          <div>
            <label htmlFor="cfg" className="block text-sm font-medium text-gray-700 mb-2">
              CFG Scale: {cfg}
            </label>
            <input
              id="cfg"
              type="range"
              min="1"
              max="20"
              step="0.5"
              value={cfg}
              onChange={(e) => setCfg(Number(e.target.value))}
              disabled={generationState !== STATE.IDLE}
              className="w-full"
            />
            <div className="flex justify-between text-xs text-gray-500">
              <span>1.0</span>
              <span>20.0</span>
            </div>
          </div>

          {/* FUN-GEN-REQUEST-014: Resolution select */}
          <div>
            <label htmlFor="resolution" className="block text-sm font-medium text-gray-700 mb-2">
              Resolution
            </label>
            <select
              id="resolution"
              value={resolution}
              onChange={(e) => setResolution(e.target.value)}
              disabled={generationState !== STATE.IDLE}
              className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="512x512">512x512 (Fast)</option>
              <option value="768x768">768x768</option>
              <option value="1024x1024">1024x1024 (Recommended)</option>
              <option value="1024x768">1024x768 (Landscape)</option>
              <option value="768x1024">768x1024 (Portrait)</option>
            </select>
          </div>

          {/* FUN-GEN-REQUEST-013: Seed input */}
          <div>
            <label htmlFor="seed" className="block text-sm font-medium text-gray-700 mb-2">
              Seed (-1 for random)
            </label>
            <input
              id="seed"
              type="number"
              value={seed}
              onChange={(e) => setSeed(Number(e.target.value))}
              disabled={generationState !== STATE.IDLE}
              className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          {/* FUN-GEN-REQUEST-008: Generate button */}
          <button
            onClick={handleGenerate}
            disabled={!canGenerate}
            className="w-full px-4 py-3 bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed flex items-center justify-center"
          >
            {generationState !== STATE.IDLE && <Loader2 className="animate-spin mr-2 h-5 w-5" />}
            {generationState === STATE.IDLE && 'Generate Image'}
            {generationState === STATE.VALIDATING && 'Validating...'}
            {generationState === STATE.SUBMITTING && 'Submitting...'}
            {generationState === STATE.QUEUED && 'Queued...'}
            {generationState === STATE.PROCESSING && 'Generating...'}
            {generationState === STATE.COMPLETED && 'Generated!'}
            {generationState === STATE.ERROR && 'Error'}
          </button>

          {errorMessage && (
            <div className="p-4 bg-red-50 border border-red-200 rounded-md">
              <p className="text-sm text-red-800">{errorMessage}</p>
              <button
                onClick={handleReset}
                className="mt-2 text-sm text-red-600 hover:text-red-800 underline"
              >
                Try Again
              </button>
            </div>
          )}
        </div>

        {/* Right: Preview */}
        <div>
          <GeneratedImage
            imageUrl={generatedImage}
            state={generationState}
            onReset={handleReset}
          />
        </div>
      </div>
    </div>
  );
}

export default GenerationForm;
