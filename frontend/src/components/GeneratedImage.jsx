/**
 * Generated Image Display Component
 * Traceability: FUN-GEN-REQUEST-015
 */
import { Download, RefreshCw } from 'lucide-react';

function GeneratedImage({ imageUrl, state, onReset }) {
  const isGenerating = ['validating', 'submitting', 'queued', 'processing'].includes(state);
  const isCompleted = state === 'completed';

  return (
    <div className="bg-gray-100 rounded-lg p-6 min-h-[500px] flex items-center justify-center">
      {state === 'idle' && (
        <div className="text-center text-gray-500">
          <p>Configure parameters and click Generate</p>
        </div>
      )}

      {isGenerating && (
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600 capitalize">{state}...</p>
        </div>
      )}

      {isCompleted && imageUrl && (
        <div className="w-full">
          <img
            src={imageUrl}
            alt="Generated"
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
              onClick={onReset}
              className="flex-1 px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 flex items-center justify-center"
            >
              <RefreshCw className="h-4 w-4 mr-2" />
              New Generation
            </button>
          </div>
        </div>
      )}

      {state === 'error' && (
        <div className="text-center text-red-600">
          <p>Generation failed</p>
          <button
            onClick={onReset}
            className="mt-4 px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700"
          >
            Try Again
          </button>
        </div>
      )}
    </div>
  );
}

export default GeneratedImage;
