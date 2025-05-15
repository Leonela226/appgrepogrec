const Giveaway = require("./admin/view_giveaway_model");
const Branch = require("./admin/branches_model");
const GiveawayPrize = require("./admin/assign_prizes_model");
const Prize = require("./admin/prizes_model");
const ParticipationPrize = require("./admin/participation_prize_model");
const Participation = require("./client/participation_model");
const CodeQR = require("./client/scanner_qr_model");
const User = require("./common/user_model");

// Relación: Giveaway -> Branch
Giveaway.belongsTo(Branch, { foreignKey: "id_branch", as: "giveawaysBranch" });
Branch.hasMany(Giveaway, { foreignKey: "id_branch", as: "giveaways" });

// Relación: Giveaway -> GiveawayPrize
Giveaway.hasMany(GiveawayPrize, { foreignKey: "id_giveaway", as: "giveawayPrizes" });
GiveawayPrize.belongsTo(Giveaway, { foreignKey: "id_giveaway", as: "giveaway" });

// Relación: Giveaway -> Participation
//Giveaway.hasMany(Participation, { foreignKey: "id_giveaway", as: "participations" });
//Participation.belongsTo(Giveaway, { foreignKey: "id_giveaway", as: "giveaway" });



// Relación: Prize -> GiveawayPrize
Prize.hasMany(GiveawayPrize, { foreignKey: "id_prize", as: "prizeAssignments" });
GiveawayPrize.belongsTo(Prize, { foreignKey: "id_prize", as: "prize" });


Participation.hasMany(ParticipationPrize, { foreignKey: "id_participation", as: "prizesWon" });
GiveawayPrize.hasMany(ParticipationPrize, { foreignKey: "id_giveaway_prize", as: "assignedPrizes" });

// Relación: CodeQR -> Participation
CodeQR.hasMany(Participation, {foreignKey: "id_codes_qr", as: "participations",});
Participation.belongsTo(CodeQR, {foreignKey: "id_codes_qr", as: "codeQR",});


//CodeQR.belongsTo(Giveaway, {foreignKey: "code_giveaway",});  // campo en codes_qrtargetKey: "code_giveaway",   // campo en giveawaysas: "giveaway"

CodeQR.belongsTo(Giveaway, { 
    foreignKey: "code_giveaway", 
    targetKey: "code_giveaway", 
    as: "giveaway"
});


// Modelo Giveaway
Giveaway.hasMany(CodeQR, {foreignKey: "code_giveaway",sourceKey: "code_giveaway",as: "codesQR"});

User.hasMany(Participation, { foreignKey: 'id_user', as: 'participations' });
Participation.belongsTo(User, { foreignKey: 'id_user', as: 'user' });
  


module.exports = () => {};
