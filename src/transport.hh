#ifndef __PEP__TRANSPORT_HH__
#define __PEP__TRANSPORT_HH__

#include <exception>
#include <functional>
#include <pEp/transport_status_code.h>

namespace pEp {
    class Transport {
        const PEP_transport_id id;

        protected:
            PEP_transport_status_code actual_status;
 
        public:
            struct TransportError : std::runtime_error {
                const PEP_transport_status_code tsc;

                TransportError(PEP_transport_status_code tsc) :
                    std::runtime_error("transport error"), tsc(tsc) { }
            };

            struct ConfigError : std::logic_error {
                ConfigError() : std::logic_error("config error") { }
            };

            class Config {
                public:
                    Config() { }
                    virtual Config& operator=(const Config& second) = 0;
                    Config(const Config& second) { *this = second; }
                    virtual ~Config() { }
            };

            Transport(PEP_transport_id id) : id(id), actual_status(0x00ffffff) { }
            Transport(const Transport&) = delete;
            Transport& operator=(const Transport&) = delete;
            virtual ~Transport() { }

            PEP_transport_id get_id() { return id; }

            // the signal_ function register signal handlers
            // they must be called while a transport is running, otherwise they
            // throw std::logic_error in case the transport is shut down

            void
                signal_statuschange(std::function(void(PEP_transport_status_code))) = 0;

            void
                signal_sendto_result(std::function(void(std::string,
                                std::string, PEP_transport_status_code))) = 0;

            void
                signal_incoming_message(std::function(void(PEP_transport_status_code))) = 0;

            virtual void configure(const Config& config) = 0;
            virtual void startup(callback_execution cbe = PEP_cbe_polling) = 0;
            virtual void shutdown() = 0;

            virtual void sendto(pEp::Message& msg) = 0;
            virtual Message recvnext() = 0;

            virtual bool shortmsg_supported() = 0;
            virtual bool longmsg_supported() = 0;
            virtual bool longmsg_formatted_supported() = 0;
            virtual PEP_text_format native_text_format() = 0;
    };
}

#endif // __PEP_TRANSPORT_HH__
