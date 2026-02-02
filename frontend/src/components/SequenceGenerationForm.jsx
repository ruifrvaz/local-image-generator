/**
 * Sequence Generation Form Component
 * Traceability: FUN-SEQUENCE-GEN
 */
import { useState } from 'react';

function SequenceGenerationForm() {
  const [storyDescription, setStoryDescription] = useState('');
  const [frameCount, setFrameCount] = useState(6);

  return (
    <div className="bg-white shadow rounded-lg p-6 mt-6">
      <h3 className="text-lg font-medium text-gray-900 mb-4">Story Sequence Generation</h3>

      {/* FUN-SEQUENCE-GEN-002: Story description */}
      <div className="mb-4">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Story Description
        </label>
        <textarea
          value={storyDescription}
          onChange={(e) => setStoryDescription(e.target.value)}
          rows={6}
          className="w-full px-3 py-2 border border-gray-300 rounded-md"
          placeholder="Describe your story in detail (100-1000 characters)..."
        />
        <p className="mt-1 text-sm text-gray-500">
          {storyDescription.length} / 1000 characters
        </p>
      </div>

      {/* FUN-SEQUENCE-GEN-003: Frame count */}
      <div className="mb-6">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Number of Frames: {frameCount}
        </label>
        <input
          type="range"
          min="3"
          max="50"
          value={frameCount}
          onChange={(e) => setFrameCount(Number(e.target.value))}
          className="w-full"
        />
        <div className="flex justify-between text-xs text-gray-500">
          <span>3</span>
          <span>50</span>
        </div>
      </div>

      {/* TODO: Integrate with scene producer agent */}
      <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-md">
        <p className="text-sm text-yellow-800">
          Story sequence generation requires scene producer agent integration.
          This feature is planned for a future release.
        </p>
      </div>
    </div>
  );
}

export default SequenceGenerationForm;
