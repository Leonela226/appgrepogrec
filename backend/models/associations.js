const Giveaway = require("./admin/view_giveaway_model");
const Branch = require("./admin/branches_model");
const GiveawayPrize = require("./admin/assign_prizes_model");
const Prize = require("./admin/prizes_model");
const ParticipationPrize = require("./admin/participation_prize_model");
const Participation = require("./client/participation_model");
const CodeQR = require("./client/scanner_qr_model");

// Relación: Giveaway -> Branch
Giveaway.belongsTo(Branch, { foreignKey: "id_branch", as: "giveawaysBranch" });
Branch.hasMany(Giveaway, { foreignKey: "id_branch", as: "giveaways" });

// Relación: Giveaway -> GiveawayPrize
Giveaway.hasMany(GiveawayPrize, { foreignKey: "id_giveaway", as: "giveawayPrizes" });
GiveawayPrize.belongsTo(Giveaway, { foreignKey: "id_giveaway", as: "giveaway" });


// Relación: Prize -> GiveawayPrize
Prize.hasMany(GiveawayPrize, { foreignKey: "id_prize", as: "prizeAssignments" });
//GiveawayPrize.belongsTo(Prize, { foreignKey: "id_prize", as: "prize" });
GiveawayPrize.belongsTo(Prize, { foreignKey: "id_prize", as: "prize" });


// Relación: ParticipationPrize -> Participation y GiveawayPrize
ParticipationPrize.belongsTo(Participation, { foreignKey: "id_participation", as: "participation" });
ParticipationPrize.belongsTo(GiveawayPrize, { foreignKey: "id_giveaway_prize", as: "giveawayPrize" });

Participation.hasMany(ParticipationPrize, { foreignKey: "id_participation", as: "prizesWon" });
GiveawayPrize.hasMany(ParticipationPrize, { foreignKey: "id_giveaway_prize", as: "assignedPrizes" });

// Relación: CodeQR -> Participation
CodeQR.hasMany(Participation, {
  foreignKey: "id_codes_qr",
  as: "participations",
});
Participation.belongsTo(CodeQR, {
  foreignKey: "id_codes_qr",
  as: "codeQR",
});

// Relación: Giveaway -> CodeQR
Giveaway.hasMany(CodeQR, {
  foreignKey: "code_giveaway",
  as: "codesQR",
});
CodeQR.belongsTo(Giveaway, {
  foreignKey: "code_giveaway",
  as: "giveaway",
});

module.exports = () => {};
