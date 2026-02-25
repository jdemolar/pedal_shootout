/**
 * Shared validation types for all connection categories (power, audio, MIDI, control).
 *
 * Validators in powerUtils, audioUtils, midiUtils, and controlUtils all return
 * ConnectionValidation so the UI can handle warnings uniformly across categories.
 */

export type ValidationSeverity = 'error' | 'warning' | 'info';

export interface ConnectionWarning {
  /** Stable identifier used to track acknowledgements. Format: `category:rule-name`. */
  key: string;
  severity: ValidationSeverity;
  message: string;
  /** Present when this warning implies a physical adapter is needed. */
  adapterImplication?: {
    fromConnectorType: string;
    toConnectorType: string;
    description: string;
  };
}

export interface ConnectionValidation {
  status: 'valid' | 'warning' | 'error';
  warnings: ConnectionWarning[];
}
