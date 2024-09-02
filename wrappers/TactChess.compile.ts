import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/tact_chess.tact',
    options: {
        debug: true,
    },
};
