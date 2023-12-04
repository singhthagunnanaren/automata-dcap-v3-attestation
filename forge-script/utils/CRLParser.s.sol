// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {LibString} from "solady/src/Milady.sol";
import {Asn1Decode, NodePtr} from "../../contracts/utils/Asn1Decode.sol";
import {BytesUtils} from "../../contracts/utils/BytesUtils.sol";
import {X509DateUtils} from "../../contracts/utils/X509DateUtils.sol";

import "forge-std/console.sol";

contract CRLParser {
    using Asn1Decode for bytes;
    using NodePtr for uint256;
    using BytesUtils for bytes;

    bytes internal constant samplePckCrl = hex'30820a6230820a08020101300a06082a8648ce3d04030230703122302006035504030c19496e74656c205347582050434b20506c6174666f726d204341311a3018060355040a0c11496e74656c20436f72706f726174696f6e3114301206035504070c0b53616e746120436c617261310b300906035504080c024341310b3009060355040613025553170d3233303932373031343631355a170d3233313032373031343631355a30820934303302146fc34e5023e728923435d61aa4b83c618166ad35170d3233303932373031343631355a300c300a0603551d1504030a01013034021500efae6e9715fca13b87e333e8261ed6d990a926ad170d3233303932373031343631355a300c300a0603551d1504030a01013034021500fd608648629cba73078b4d492f4b3ea741ad08cd170d3233303932373031343631355a300c300a0603551d1504030a010130340215008af924184e1d5afddd73c3d63a12f5e8b5737e56170d3233303932373031343631355a300c300a0603551d1504030a01013034021500b1257978cfa9ccdd0759abf8c5ca72fae3a78a9b170d3233303932373031343631355a300c300a0603551d1504030a01013033021474fea614a972be0e2843f2059835811ed872f9b3170d3233303932373031343631355a300c300a0603551d1504030a01013034021500f9c4ef56b3ab48d577e108baedf4bf88014214b9170d3233303932373031343631355a300c300a0603551d1504030a010130330214071de0778f9e5fc4f2878f30d6b07c9a30e6b30b170d3233303932373031343631355a300c300a0603551d1504030a01013034021500cde2424f972cea94ff239937f4d80c25029dd60b170d3233303932373031343631355a300c300a0603551d1504030a0101303302146c3319e5109b64507d3cf1132ce00349ef527319170d3233303932373031343631355a300c300a0603551d1504030a01013034021500df08d756b66a7497f43b5bb58ada04d3f4f7a937170d3233303932373031343631355a300c300a0603551d1504030a01013033021428af485b6cf67e409a39d5cb5aee4598f7a8fa7b170d3233303932373031343631355a300c300a0603551d1504030a01013034021500fb8b2daec092cada8aa9bc4ff2f1c20d0346668c170d3233303932373031343631355a300c300a0603551d1504030a01013034021500cd4850ac52bdcc69a6a6f058c8bc57bbd0b5f864170d3233303932373031343631355a300c300a0603551d1504030a01013034021500994dd3666f5275fb805f95dd02bd50cb2679d8ad170d3233303932373031343631355a300c300a0603551d1504030a0101303302140702136900252274d9035eedf5457462fad0ef4c170d3233303932373031343631355a300c300a0603551d1504030a01013033021461f2bf73e39b4e04aa27d801bd73d24319b5bf80170d3233303932373031343631355a300c300a0603551d1504030a0101303302143992be851b96902eff38959e6c2eff1b0651a4b5170d3233303932373031343631355a300c300a0603551d1504030a010130330214639f139a5040fdcff191e8a4fb1bf086ed603971170d3233303932373031343631355a300c300a0603551d1504030a01013034021500959d533f9249dc1e513544cdc830bf19b7f1f301170d3233303932373031343631355a300c300a0603551d1504030a0101303302140fda43a00b68ea79b7c2deaeac0b498bdfb2af90170d3233303932373031343631355a300c300a0603551d1504030a010130340215009d67753b81e47090aea763fbec4c4549bcdb9933170d3233303932373031343631355a300c300a0603551d1504030a01013033021434bfbb7a1d9c568147e118b614f7b76ed3ef68df170d3233303932373031343631355a300c300a0603551d1504030a0101303402150085d3c9381b77a7e04d119c9e5ad6749ff3ffab87170d3233303932373031343631355a300c300a0603551d1504030a0101303402150093887ca4411e7a923bd1fed2819b2949f201b5b4170d3233303932373031343631355a300c300a0603551d1504030a0101303302142498dc6283930996fd8bf23a37acbe26a3bed457170d3233303932373031343631355a300c300a0603551d1504030a010130340215008a66f1a749488667689cc3903ac54c662b712e73170d3233303932373031343631355a300c300a0603551d1504030a01013034021500afc13610bdd36cb7985d106481a880d3a01fda07170d3233303932373031343631355a300c300a0603551d1504030a01013034021500efe04b2c33d036aac96ca673bf1e9a47b64d5cbb170d3233303932373031343631355a300c300a0603551d1504030a0101303402150083d9ac8d8bb509d1c6c809ad712e8430559ed7f3170d3233303932373031343631355a300c300a0603551d1504030a0101303302147931fd50b5071c1bbfc5b7b6ded8b45b9d8b8529170d3233303932373031343631355a300c300a0603551d1504030a0101303302141fa20e2970bde5d57f7b8ddf8339484e1f1d0823170d3233303932373031343631355a300c300a0603551d1504030a0101303302141e87b2c3b32d8d23e411cef34197b95af0c8adf5170d3233303932373031343631355a300c300a0603551d1504030a010130340215009afd2ee90a473550a167d996911437c7502d1f09170d3233303932373031343631355a300c300a0603551d1504030a0101303302144481b0f11728a13b696d3ea9c770a0b15ec58dda170d3233303932373031343631355a300c300a0603551d1504030a01013034021500a7859f57982ef0e67d37bc8ef2ef5ac835ff1aa9170d3233303932373031343631355a300c300a0603551d1504030a0101303302147ae37748a9f912f4c63ba7ab07c593ce1d1d1181170d3233303932373031343631355a300c300a0603551d1504030a01013033021413884b33269938c195aa170fca75da177538df0b170d3233303932373031343631355a300c300a0603551d1504030a0101303302142c3cc6fe9279db1516d5ce39f2a898cda5a175e1170d3233303932373031343631355a300c300a0603551d1504030a010130330214717948687509234be979e4b7dce6f31bef64b68c170d3233303932373031343631355a300c300a0603551d1504030a010130340215009d76ef2c39c136e8658b6e7396b1d7445a27631f170d3233303932373031343631355a300c300a0603551d1504030a01013034021500c3e025fca995f36f59b48467939e3e34e6361a6f170d3233303932373031343631355a300c300a0603551d1504030a010130340215008c5f6b3257da05b17429e2e61ba965d67330606a170d3233303932373031343631355a300c300a0603551d1504030a01013034021500a17c51722ec1e0c3278fe8bdf052059cbec4e648170d3233303932373031343631355a300c300a0603551d1504030a0101a02f302d300a0603551d140403020101301f0603551d23041830168014956f5dcdbd1be1e94049c9d4f433ce01570bde54300a06082a8648ce3d0403020348003045022100b0a342c3079be843846bf79284498469b842f3230d0e6e32f27f728ce9ae6bd602202e4f5ff1ee7f2ef1de39fd177b8eddc0c98b82ac65b0ce34c18c06ac50285b16';
    // bytes internal constant sampleRootCrl = hex"308201213081C8020101300A06082A8648CE3D0403023068311A301806035504030C11496E74656C2053475820526F6F74204341311A3018060355040A0C11496E74656C20436F72706F726174696F6E3114301206035504070C0B53616E746120436C617261310B300906035504080C024341310B3009060355040613025553170D3233303430333130323235315A170D3234303430323130323235315AA02F302D300A0603551D140403020101301F0603551D2304183016801422650CD65A9D3489F383B49552BF501B392706AC300A06082A8648CE3D0403020348003045022051577D47D9FBA157B65F1EB5F4657BBC5E56CCAF735A03F1B963D704805AB118022100939015EC1636E7EAFA5F426C1E402647C673132B6850CABD68CEF6BAD7682A03";

    function decodeCrl(bytes memory der) internal view returns (bytes[] memory revokedSerialNums) {
        uint256 root = der.root();

        // Entering tbsCertificate sequence
        uint256 tbsParentPtr = der.firstChildOf(root);

        // Begin iterating through the descendants of tbsCertificate
        uint256 tbsPtr = der.firstChildOf(tbsParentPtr);

        // The revoked serial numbers are located in the SubjectPublishKeyInfo object
        // which is 5 elements down from the first element of tbsCertificate

        tbsPtr = der.nextSiblingOf(tbsPtr);
        tbsPtr = der.nextSiblingOf(tbsPtr);
        tbsPtr = der.nextSiblingOf(tbsPtr);
        tbsPtr = der.nextSiblingOf(tbsPtr);
        tbsPtr = der.nextSiblingOf(tbsPtr);

        uint256 revokedParentPtr = der.firstChildOf(tbsPtr);
        uint256 i = 0;
        revokedSerialNums = new bytes[](44); // varies
        while (revokedParentPtr.ixl() != tbsPtr.ixl()) {
            uint256 revokedPtr = der.firstChildOf(revokedParentPtr);
            revokedParentPtr = der.nextSiblingOf(revokedParentPtr);
            revokedSerialNums[i++] = der.bytesAt(revokedPtr);
            console.logBytes(der.bytesAt(revokedPtr));
        }
        uint256 revokedPtr = der.firstChildOf(revokedParentPtr);
        revokedSerialNums[i] = der.bytesAt(revokedPtr);

        return revokedSerialNums;
    }
}