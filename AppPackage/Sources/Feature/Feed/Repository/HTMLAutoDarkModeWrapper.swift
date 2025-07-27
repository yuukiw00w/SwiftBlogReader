import Foundation

public struct HTMLAutoDarkModeWrapper {
    public init() {}

    public func callAsFunction(_ content: String?) -> String? {
        guard let bodyContent = content else {
            return nil
        }
        let css = """
        <style>
        body {
            font-family: -apple-system;
            font-size: 16px;
            color: black;
            background-color: white;
            line-height: 1.6;
            padding: 16px;
        }
        a {
            color: #1a0dab;
        }
        img {
            max-width: 100%%;
            height: auto;
        }
        @media (prefers-color-scheme: dark) {
            body {
                color: white;
                background-color: #121212;
            }
            a {
                color: #8ab4f8;
            }
        }
        </style>
        """

        return """
        <html>
        <head>
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
        \(css)
        </head>
        <body>
        \(bodyContent)
        </body>
        </html>
        """
    }
}
