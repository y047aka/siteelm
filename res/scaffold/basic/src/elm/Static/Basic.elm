module Static.Basic exposing (main)

import Html exposing (Html, div, h2, li, text, ul)
import Html.Attributes exposing (class, href)
import Json.Decode as D exposing (Decoder)
import Markdown
import Siteelm.Html as Html
import Siteelm.Html.Attributes exposing (charset, rel)
import Siteelm.Page exposing (Page, page)
import Static.View as View


main : Page Preamble
main =
    page
        { decoder = preambleDecoder
        , head = viewHead
        , body = viewBody
        }


{-| Preamble is what you write on the head of the content files.
-}
type alias Preamble =
    { title : String
    , products : List Product
    , recommends : List Product
    }


type alias Product =
    { name : String
    , price : Int
    }


{-| Preamble is passed as a JSON string. So it requires a decoder.
-}
preambleDecoder : Decoder Preamble
preambleDecoder =
    D.map3 Preamble
        (D.field "title" D.string)
        (D.field "products" (D.list productDecoder))
        (D.field "recommends" (D.list productDecoder))


productDecoder : Decoder Product
productDecoder =
    D.map2 Product
        (D.field "name" D.string)
        (D.field "price" D.int)


{-| Make contents inside the _head_ tag.
-}
viewHead : Preamble -> String -> List (Html Never)
viewHead preamble _ =
    [ Html.meta [ charset "utf-8" ]
    , Html.title [] (preamble.title ++ "| sample site")
    , Html.link [ rel "stylesheet", href "/style.css" ]
    , Html.link [ rel "stylesheet", href "https://fonts.googleapis.com/css?family=Questrial&display=swap" ]
    ]


{-| Make contents inside the _body_ tag. The parameter "body" is usually something like markdown.
-}
viewBody : Preamble -> String -> List (Html Never)
viewBody preamble body =
    [ View.header
    , div []
        [ h2 [] [ text "body text" ]
        , div [ class "inner" ]
            [ text "since the body text is just a string, give it to a markdown parser"
            , Markdown.toHtml [] body
            ]
        ]
    , div []
        [ h2 [] [ text "dynamic components" ]
        , div [ class "inner" ]
            [ text "with Browser.component, dynamic contents can be embedded"
            , Html.dynamic
                { moduleName = "Dynamic.Counter"
                , flags = "{value: 100}"
                }
            ]
        ]
    , div []
        [ h2 [] [ text "preamble" ]
        , div [ class "inner" ]
            [ text "you can write YAML in the preamble section"
            , viewProducts preamble.products
            ]
        , div
            [ class "inner" ]
            [ text "external YAML files can be imported"
            , viewProducts preamble.recommends
            ]
        ]
    ]


viewProducts : List Product -> Html Never
viewProducts =
    ul [ class "products" ]
        << List.map
            (\x ->
                li []
                    [ div [] [ text x.name ]
                    , div [] [ text ("¥" ++ String.fromInt x.price) ]
                    ]
            )
