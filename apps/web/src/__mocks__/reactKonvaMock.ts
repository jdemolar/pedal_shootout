import React from 'react';

const createMockComponent = (name: string) => {
  return React.forwardRef((props: any, ref: any) => {
    const { children, ...rest } = props;
    return React.createElement(name, { ...rest, ref }, children);
  });
};

export const Stage = createMockComponent('Stage');
export const Layer = createMockComponent('Layer');
export const Rect = createMockComponent('Rect');
export const Text = createMockComponent('Text');
export const Group = createMockComponent('Group');
export const Line = createMockComponent('Line');
export const Arrow = createMockComponent('Arrow');
export const Circle = createMockComponent('Circle');
