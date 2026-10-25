#define SDL_MAIN_USE_CALLBACKS

#include "app_state.hpp"

#include <SDL3/SDL_main.h>
#include <memory>

auto SDL_AppInit(void** appstate, [[maybe_unused]] int argc, [[maybe_unused]] char** argv)
    -> SDL_AppResult {
    auto state = std::make_unique<AppState>();

    *appstate = state.release();
    return SDL_APP_CONTINUE;
}

auto SDL_AppIterate([[maybe_unused]] void* appstate) -> SDL_AppResult {
    return SDL_APP_CONTINUE;
}

auto SDL_AppEvent([[maybe_unused]] void* appstate, [[maybe_unused]] SDL_Event* event)
    -> SDL_AppResult {
    return SDL_APP_CONTINUE;
}

auto SDL_AppQuit(void* appstate, [[maybe_unused]] SDL_AppResult result) -> void {
    {
        auto state = std::unique_ptr<AppState>(static_cast<AppState*>(appstate));
    }

    SDL_Quit();
}
