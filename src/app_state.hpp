#ifndef CNC_APP_STATE_HPP
#define CNC_APP_STATE_HPP
#pragma once

#include <SDL3/SDL.h>
#include <memory>

struct AppState {
private:
    struct SDLDeleter {
        void operator()(SDL_Window* window) const {
            if (window != nullptr) {
                SDL_DestroyWindow(window);
            }
        }

        void operator()(SDL_Renderer* renderer) const {
            if (renderer != nullptr) {
                SDL_DestroyRenderer(renderer);
            }
        }
    };

public:
    std::shared_ptr<SDL_Window> window{nullptr, SDLDeleter{}};
    std::shared_ptr<SDL_Renderer> renderer{nullptr, SDLDeleter{}};
};

#endif // CNC_APP_STATE_HPP